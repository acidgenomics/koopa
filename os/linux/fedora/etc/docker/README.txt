Docker daemon configuration (19.03.4)
Updated 2019-11-06.

Note that devicemapper is deprecated in favor of overlay2 (v18.09.0+).
https://docs.docker.com/engine/deprecated/#device-mapper-storage-driver

WARNING: the devicemapper storage-driver is deprecated, and will be removed in a
future release.

WARNING: devicemapper: usage of loopback devices is strongly discouraged for
production use. Use `--storage-opt dm.thinpooldev` to specify a custom block
storage device.
