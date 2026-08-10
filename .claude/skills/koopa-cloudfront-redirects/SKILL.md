---
name: koopa-cloudfront-redirects
description: >-
  Path-scoped HTTP redirects (e.g. root-only) on an S3+CloudFront-hosted
  domain, using native AWS mechanisms instead of a hand-placed HTML stub.
  Use when asked to redirect one path on a domain without redirecting the
  whole site, when deciding between S3 redirect metadata and a CloudFront
  Function, or when a curl-based verification is returning unexpected
  200s where a 301 was expected.
---

# CloudFront/S3 Path-Scoped Redirects

## Why Route 53 can't do this

DNS resolves names to addresses; it has no HTTP layer and cannot distinguish
one path from another. Alias records point at a resource, they never
redirect. Any redirect that must apply to some paths but not others has to
happen at S3 or CloudFront, never at the DNS layer.

## Which origin type you have decides which options exist

```sh
aws --profile <profile> cloudfront get-distribution-config --id <dist-id> \
  --query 'DistributionConfig.Origins.Items[].DomainName'
```

- **`<bucket>.s3-website-<region>.amazonaws.com`** (S3 *website* endpoint) —
  honors `x-amz-website-redirect-location` object metadata and returns a
  real `301`. Both mechanisms below are available.
- **`<bucket>.s3.<region>.amazonaws.com`** or an OAC/OAI REST origin — ignores
  that metadata entirely. A CloudFront Function is the *only* option.

## Two mechanisms, and when each is authoritative

| Mechanism | Like an Apache... | Scope | Survives a content resync? |
|---|---|---|---|
| S3 object redirect metadata (`--website-redirect-location`) | per-file `Redirect` directive | one S3 key | No — a rebuild that overwrites that object's content also drops its metadata |
| CloudFront Function (`viewer-request`) | `mod_rewrite` rule | any path pattern, edge-side | Yes — lives on the distribution, independent of bucket contents |

If the origin content is still rebuilt and re-synced periodically (a static
site generator, a docs publish job, etc.), **the CloudFront Function must be
the authoritative layer** and S3 metadata, if added at all, is only a
fallback for when the function is ever detached. Getting the layering
backwards means the redirect silently disappears on the next publish.

## CloudFront Function: create, test, publish, associate

```js
// One example shape — a root-only redirect. Match only what should redirect;
// everything else must fall through via `return event.request`.
function handler(event) {
  var uri = event.request.uri;
  if (uri === '/' || uri === '/index.html') {
    return {
      statusCode: 301,
      statusDescription: 'Moved Permanently',
      headers: { location: { value: 'https://target.example.com/' } }
    };
  }
  return event.request;
}
```

```sh
aws --profile <profile> cloudfront create-function \
  --name <fn-name> \
  --function-config 'Comment=<comment>,Runtime=cloudfront-js-2.0' \
  --function-code fileb://path/to/function.js
# Returns an ETag — needed for the next two calls.
```

**Test before publishing** — `--event-object` must be a `fileb://` file
containing the *plain* event object, not the `{"EventObject": "..."}`
wrapper the CLI docs sometimes imply:

```sh
cat > /tmp/event.json <<'EOF'
{"version":"1.0","context":{"eventType":"viewer-request"},
 "viewer":{"ip":"1.2.3.4"},
 "request":{"method":"GET","uri":"/","headers":{},"cookies":{},"querystring":{}}}
EOF
aws --profile <profile> cloudfront test-function \
  --name <fn-name> --if-match <etag> --stage DEVELOPMENT \
  --event-object fileb:///tmp/event.json
```

Wrapping the event in `{"EventObject": ...}` fails with `Invalid base64` —
the CLI expects to base64-encode the raw event content itself, not a JSON
envelope around it. Test every distinct URI shape (the redirected path, and
at least one path that must pass through untouched) before publishing.

```sh
aws --profile <profile> cloudfront publish-function \
  --name <fn-name> --if-match <etag>
```

Associating with a distribution is a **read-modify-write** of the whole
config, not a targeted field update:

```sh
aws --profile <profile> cloudfront get-distribution-config --id <dist-id> \
  > /tmp/dist-config.json
# Edit only DistributionConfig.DefaultCacheBehavior.FunctionAssociations to
# {"Quantity": 1, "Items": [{"FunctionARN": "<published-arn>", "EventType": "viewer-request"}]}
# Preserve every other field verbatim (aliases, ViewerProtocolPolicy, ForwardedValues, etc.)
aws --profile <profile> cloudfront update-distribution --id <dist-id> \
  --distribution-config file:///tmp/dist-config.json --if-match <config-etag>
```

Deployment (`Status: InProgress` → `Deployed`) takes a few minutes; poll with
`get-distribution --query 'Distribution.Status'`.

## S3 fallback layer

```sh
aws --profile <profile> s3api copy-object \
  --bucket <bucket> --key <key> --copy-source '<bucket>/<key>' \
  --website-redirect-location 'https://target.example.com/' \
  --content-type 'text/html' --metadata-directive REPLACE
```

`--metadata-directive REPLACE` drops every metadata field not explicitly
restated (hence passing `--content-type` even though it isn't changing).
`copy-source == key` is a same-object metadata-only update, not an actual
copy elsewhere.

## Verification gotcha: a `~/.curlrc` with `location` masks every redirect

If `~/.curlrc` sets `location` (auto-follow), every plain `curl -o /dev/null
-w '%{http_code}'` check against a redirected path reports the *final*
destination's status, not the redirect itself — a `301` silently reads as a
`200`, making the fix look like it did nothing. Override per-invocation:

```sh
curl -sS --no-location -o /dev/null -w '%{http_code} %{redirect_url}\n' <url>
```

Check `~/.curlrc` for a bare `location` line before concluding a redirect
isn't working from curl output alone.

## Invalidate only the changed paths

```sh
aws --profile <profile> cloudfront create-invalidation --distribution-id <dist-id> \
  --paths / /index.html
```

Scope to the specific paths that changed rather than `/*` — a root-only
redirect fix has no reason to force a refetch of every cached asset.
