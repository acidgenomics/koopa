#
# vcr.py
#  - Configures the environment for running the Viral Assembly (viral_assembly_pipeline.py) and VIGOR (VIGOR3.pl) pipelines (creating directory structure and installs software). 
#

from __future__ import print_function
import os.path, re, mmap
from fabric.api import cd, env, hide, local, run, settings, sudo, task
from fabric.network import disconnect_all

# Common variables
dependency_URL = "http://s3.amazonaws.com/VIGOR-GSC"


# Galaxy VCR
galaxy_central = "/mnt/galaxyTools/galaxy-central"
galaxy_VCR_path = "/%s/tools/viral_assembly_annotation" % galaxy_central

# Galaxy VCR - install method
def install_galaxy_vcr(env):
	with cd("~"):
		print("Installing galaxy VCR tools (python and xml scripts).")
		sudo("git clone git://github.com/JCVI-Cloud/galaxy-tools-vcr.git")
		sudo("cp -R galaxy-tools-vcr/tools/viral_assembly_annotation %s" % galaxy_VCR_path)
		sudo("chown -R galaxy:galaxy %s" % galaxy_VCR_path)
	with cd(galaxy_central):
		print("Adding VCR to tool_conf.xml.")
		tcx_file = "tool_conf.xml"
		_set_pre_VCR(tcx_file,"galaxy","galaxy")
		tcx_string = _get_file_string(tcx_file,galaxy_central)
		
		vcr_header = "<section name=\"Viral Assembly and Annotation\" id=\"viral_assembly_annotation\">\""
		if (tcx_string.find(vcr_header) != -1):
			print("Galaxy VCR tools already included in tools_conf.xml!")
		else:
			sudo("sed -i '$d' %s/%s" % (galaxy_central,tcx_file))
			sudo("echo -e '  <section name=\"Viral Assembly and Annotation\" id=\"viral_assembly_annotation\">' >> %s" % tcx_file)
			sudo("echo -e '    <tool file=\"viral_assembly_annotation/viral_assembly.xml\" />' >> %s" % tcx_file)
			sudo("echo -e '    <tool file=\"viral_assembly_annotation/VIGOR.xml\" />' >> %s" % tcx_file)
			sudo("echo -e '  </section>' >> %s" % tcx_file)
			sudo("echo -e '</toolbox>' >> %s" % tcx_file)
		
		print("Adding 'sanitize_all_html = False' to universe_wsgi.ini to enable JBrowse for VICVB.")
		uwi_file = "universe_wsgi.ini"
		_set_pre_VCR(uwi_file,"galaxy","galaxy")
		uwi_string = _get_file_string(uwi_file,galaxy_central)
		
		if (uwi_string.find("sanitize_all_html") != -1):
			print("Setting sanitize_all_html in %s to False." % uwi_file)
			sudo("sed -i '/^sanitize_all_html/c\sanitize_all_html = False' %s" % uwi_file)
		else:
			print("No sanitize_all_html present! Adding...")
			sudo("sed -i '/^\[app:main\]/a\\\nsanitize_all_html = False' %s" % uwi_file)


# Viral Assembly
viral_dirs = {}
viral_urls = {}
viral_tars = {}

# Viral Assembly - install methods
def install_viralassembly(env):
	try:
		_initialize_area_viral()
		_add_tools_viral()
		_add_refs()
		sudo("chmod -R 755 %(VIRAL_ROOT_DIR)s" % env)
	finally:
		disconnect_all()

def install_viralassembly_cleanall(env):
	try:
		_initialize_env("viral")
		_remove_dir("%(VIRAL_ROOT_DIR)s" % env)
		print("Viral Assembly Removed\n")
	finally:
		disconnect_all()

# Viral Assembly - utility methods

def _initialize_area_viral():
	_initialize_env("viral")
	
	env.VIRAL_SCRIPT = "%s/viral_assembly_pipeline.py" % dependency_URL
	
	viral_dirs["PROJECT_DIR"] = "%(VIRAL_ROOT_DIR)s/project" % env
	viral_dirs["REF_DIR"] = "%(VIRAL_ROOT_DIR)s/references"  % env
	viral_dirs["TOOLS_DIR"] = "%(VIRAL_ROOT_DIR)s/tools"     % env
	viral_dirs["TOOLS_BINARIES_DIR"] = "%s/BINARIES"         % viral_dirs["TOOLS_DIR"]
	viral_dirs["TOOLS_PERL_DIR"] = "%s/PERL"                 % viral_dirs["TOOLS_DIR"]
	
	env.VIRAL_REF_FILES = "corona_virus,hadv,influenza_a_virus,jev,mpv,norv,rota_virus,rsv,veev,vzv,yfv"
	
	viral_urls["BIO_LINUX_URL"] = "http://nebc.nerc.ac.uk/bio-linux/"
	
	viral_tars["BINARIES_TARBALL"] = "BINARIES.tgz"
	viral_tars["PERL_TARBALL"] = "PERL.tgz"
	
	print("user:   %(user)s" % env)
	print("host:   %(host)s" % env)
	print("ROOT DIR:   %(VIRAL_ROOT_DIR)s" % env)
	print("VIRAL ASSEMBLY SCRIPT:   %(VIRAL_SCRIPT)s" % env)
	for name in sorted(viral_dirs.keys()):
		if not _path_is_dir(viral_dirs[name]):
			sudo("mkdir -p %s" % viral_dirs[name])
		print("%s:   %s" % (name,viral_dirs[name]))
	print("VIRAL ASSEMBLY REFS FILES: %(VIRAL_REF_FILES)s" % env)
	for name in sorted(viral_urls.keys()):
		print("%s:   %s" % (name,viral_urls[name]))
	for name in sorted(viral_tars.keys()):
		print("%s:   %s" % (name,viral_tars[name]))

def _add_tools_viral():
	with cd("/home/ubuntu/"):
		bashrc_file = ".bashrc"
		_set_pre_VCR(bashrc_file,"ubuntu","ubuntu")
		bashrc_string = _get_file_string(bashrc_file,"/home/ubuntu/")
		
		if (bashrc_string.find("DEBIAN_FRONTEND") != -1):
			print("Setting DEBIAN_FRONTEND in %s to noninteractive." % bashrc_file)
			sudo("sed -i \"/DEBIAN_FRONTEND/c\DEBIAN_FRONTEND=noninteractive\" %s/%s" % ("/home/ubuntu",bashrc_file))
		else:
			print("No DEBIAN_FRONTEND present! Adding...")
			sudo("echo -e \"DEBIAN_FRONTEND=noninteractive\" >> %s" % bashrc_file)
	
	sudo("wget --no-check-certificate -O %s/viral_assembly_pipeline.py %s" % (env.VIRAL_ROOT_DIR,env.VIRAL_SCRIPT))
	_add_package(dependency_URL,viral_tars["BINARIES_TARBALL"],viral_dirs["TOOLS_BINARIES_DIR"],"tar")
	_add_package(dependency_URL,viral_tars["PERL_TARBALL"],viral_dirs["TOOLS_PERL_DIR"],"tar")
	_apt_get_install("csh")
	_apt_get_install("gawk")
	_initialize_bio_linux()

def _add_refs():
	files = (env.VIRAL_REF_FILES).split(",")
	for file in files:
		_add_package(dependency_URL,"%s.tgz" % file,viral_dirs["REF_DIR"],"tar")

def _initialize_bio_linux():
	sudo("echo -e \"deb %s unstable bio-linux\" >> /etc/apt/sources.list" % viral_urls["BIO_LINUX_URL"])
	sudo("sudo apt-get update")
	_apt_get_install("bio-linux-keyring")
	_apt_get_install("bwa")
	_apt_get_install("samtools")
	_apt_get_install("bio-linux-cap3")
	_apt_get_install("emboss")


# VIGOR

vigor_dirs = {}
vigor_urls = {}
vigor_tars = {}
vigor_names = {}

# VIGOR - install methods

def install_viralvigor(env):
	try:
		_initialize_area_vigor()
		_initialize_host()
		_add_vigor()
		_add_tools_vigor()
	finally:
		disconnect_all()

def install_viralvigor_test(env):
	try:
		_initialize_area_vigor()
		cmd = ("""%s/VIGOR3.pl \
				-D yfv \
				-i %s/westnile.fasta \
				-O %s/westnile \
				> %s/westnile_test_run.log 2>&1 \
				""") % (vigor_dirs["VIGOR_RUNTIME_DIR"],vigor_dirs["VIGOR_SAMPLE_DATA_DIR"],vigor_dirs["VIGOR_TEST_OUTPUT_DIR"],env.VIGOR_SCRATCH_DIR)
		print("DEBUG: cmd[%s]" % cmd)
		run(cmd)
	finally:
		disconnect_all()

def install_viralvigor_validate(env):
	try:
		_initialize_area_vigor()
		sudo("rm -f %s/westnile.rpt" % vigor_dirs["VIGOR_TEST_OUTPUT_DIR"])
		sudo("rm -f %s/westnile.rpt" % vigor_dirs["VIGOR_SAMPLE_DATA_DIR"])
		with settings(hide("running","stdout")):
			results = run("""diff -Bwr %s %s || echo 'VALIDATION FAILED'""" % (vigor_dirs["VIGOR_SAMPLE_DATA_DIR"],vigor_dirs["VIGOR_TEST_OUTPUT_DIR"]))
		if results:
			print("\n\nValidation Failed:\n\n%s\n" % results)
	finally:
		disconnect_all()

def install_viralvigor_cleanall(env):
	try:
		_initialize_env("vigor")
		_remove_dir(env.VIGOR_ROOT_DIR)
		_remove_dir(env.VIGOR_SCRATCH_DIR)
		print("Vigor Removed\n")
	finally:
		disconnect_all()

# VIGOR - utility methods

def _initialize_area_vigor():
	machine = run("uname -m")
	
	if machine.find('64')>0:
		env.ARCH = 'x64-linux'
	else:
		env.ARCH = 'ia32-linux'
	
	_initialize_env("vigor")
	
	vigor_dirs["TOOLS_DIR"] = "%s/tools"                                     % env.VIGOR_ROOT_DIR
	vigor_dirs["VIGOR_STORED_DIR"] = "%s/vigor"                              % vigor_dirs["TOOLS_DIR"]
	vigor_dirs["VIGOR_RUNTIME_DIR"] = "%s/prod3"                             % vigor_dirs["VIGOR_STORED_DIR"]
	vigor_dirs["VIGOR_TEMPSPACE_DIR"] = "%s/tempspace"                       % env.VIGOR_SCRATCH_DIR
	vigor_dirs["VIGOR_SAMPLE_DATA_DIR"] = "%s/samples"                       % vigor_dirs["VIGOR_STORED_DIR"]
	vigor_dirs["VIGOR_TEST_OUTPUT_DIR"] = "%s/test"                          % vigor_dirs["VIGOR_STORED_DIR"]
	vigor_dirs["BLAST_DIR"] = "%s/blast"                                     % vigor_dirs["TOOLS_DIR"]
	vigor_dirs["CLUSTALW_DIR"] = "%s/clustalw"                               % vigor_dirs["TOOLS_DIR"]
	vigor_dirs["EXE_DIR"] = vigor_dirs["VIGOR_RUNTIME_DIR"]
	
	vigor_names["BLAST_NAME"] = 'blast-2.2.15'
	vigor_names["CLUSTALW_NAME"] = 'clustalw-1.83'
	vigor_names["VIGOR_NAME"] = 'vigor-GSCcloud'
	
	vigor_tars["VIGOR_TAR_FILENAME"] = "%s.tgz"                              % vigor_names["VIGOR_NAME"]
	vigor_tars["BLAST_TAR_FILENAME"] = "%s-%s.tar.gz"                        % (vigor_names["BLAST_NAME"],env.ARCH)
	vigor_tars["CLUSTALW_TAR_FILENAME"] = "%s-%s.deb"                        % (vigor_names["CLUSTALW_NAME"],env.ARCH)
	
	print("user:   %(user)s" % env)
	print("host:   %(host)s" % env)
	print("ARCH:   %(ARCH)s" % env)
	print("ROOT DIR:   %(VIGOR_ROOT_DIR)s" % env)
	print("SCRATCH DIR:   %(VIGOR_SCRATCH_DIR)s" % env)
	for name in sorted(vigor_dirs.keys()):
		print("%s:   %s" % (name,vigor_dirs[name]))
	for name in sorted(vigor_urls.keys()):
		print("%s:   %s" % (name,vigor_urls[name]))
	print("BLAST_NAME:   %s" % vigor_names["BLAST_NAME"])
	print("CLUSTALW_NAME:   %s" % vigor_names["CLUSTALW_NAME"])
	print("VIGOR_NAME:   %s" % vigor_names["VIGOR_NAME"])
	for name in sorted(vigor_tars.keys()):
		print("%s:   %s" % (name,vigor_tars[name]))

def _initialize_host():
	local("ssh-keygen -R %(host)s" % env)
	_fix_etc_hosts()
	_create_vigor_scratch_dir()

def _add_vigor():
	print("Installing VIGOR...")
	_create_vigor_tempspace_dir()
	_create_vigor_scratch_dir()
	_add_package(dependency_URL, vigor_tars["VIGOR_TAR_FILENAME"], vigor_dirs["VIGOR_STORED_DIR"], "tar")
	sudo("chmod 755 %s" % os.path.join(vigor_dirs["VIGOR_RUNTIME_DIR"], "*.pl"))
	if not _path_exists(os.path.join(vigor_dirs["EXE_DIR"], "perl")):
		sudo("ln -sf %s %s" % ("/usr/bin/perl", vigor_dirs["EXE_DIR"]))
		sudo("ln -sf %s %s" % ("/usr/bin/perl", "/usr/local/bin"))
	if not _path_exists(os.path.join(vigor_dirs["EXE_DIR"], "vigorscratch")):
		sudo("ln -sf %s %s/vigorscratch" % (vigor_dirs["VIGOR_TEMPSPACE_DIR"], vigor_dirs["EXE_DIR"]))

def _add_tools_vigor():
	print("Install tools...")
	_create_tools_dir()
	_add_blast()
	_add_clustalw()
	_apt_get_install("libapache-dbi-perl")
	_apt_get_install("libclass-dbi-sqlite-perl")

def _fix_etc_hosts():
	internal_ip = sudo("hostname")
	print("internal_ip[%s]" % internal_ip)
	filespec = "/etc/hosts"
	sudo("echo '127.0.0.1 %s' >> %s" % (internal_ip, filespec))

def _create_vigor_tempspace_dir():
	if not _path_is_dir(vigor_dirs["VIGOR_TEMPSPACE_DIR"]):
		sudo("mkdir -p %s" % vigor_dirs["VIGOR_TEMPSPACE_DIR"])
		sudo("chown -R %s:%s %s" % (env.user, env.user, vigor_dirs["VIGOR_TEMPSPACE_DIR"]))
		sudo("find %s -type d -exec chmod 777 {} \;" % vigor_dirs["VIGOR_TEMPSPACE_DIR"])

def _create_vigor_scratch_dir():
	if not _path_is_dir(env.VIGOR_SCRATCH_DIR):
		sudo("mkdir -p %s" % env.VIGOR_SCRATCH_DIR)
	sudo("find %s -type f -exec chmod 666 {} \;" % env.VIGOR_SCRATCH_DIR)
	sudo("find %s -type d -exec chmod 777 {} \;" % env.VIGOR_SCRATCH_DIR)

def _create_tools_dir():
	if not _path_is_dir(vigor_dirs["TOOLS_DIR"]):
		sudo("mkdir -p %s" % vigor_dirs["TOOLS_DIR"])
	sudo("chown -R %s:%s %s" % (env.user,env.user,vigor_dirs["TOOLS_DIR"]))

def _add_blast():
	print("    Installing blast...")
	_create_tools_dir()
	_add_package(dependency_URL, vigor_tars["BLAST_TAR_FILENAME"], vigor_dirs["BLAST_DIR"], "tar")
	if not _path_exists(os.path.join(vigor_dirs["EXE_DIR"], "blastall")):
		sudo("ln -sf %s %s" % (os.path.join(vigor_dirs["BLAST_DIR"], vigor_names["BLAST_NAME"], "bin", "bl2seq"), vigor_dirs["EXE_DIR"]))
		sudo("ln -sf %s %s" % (os.path.join(vigor_dirs["BLAST_DIR"], vigor_names["BLAST_NAME"], "bin", "blastall"), vigor_dirs["EXE_DIR"]))
		sudo("ln -sf %s %s" % (os.path.join(vigor_dirs["BLAST_DIR"], vigor_names["BLAST_NAME"], "bin", "fastacmd"), vigor_dirs["EXE_DIR"]))
		sudo("ln -sf %s %s" % (os.path.join(vigor_dirs["BLAST_DIR"], vigor_names["BLAST_NAME"], "bin", "formatdb"), vigor_dirs["EXE_DIR"]))

def _add_clustalw():
	print("    Installing clustalw...")
	_create_tools_dir()
	_add_package(dependency_URL, vigor_tars["CLUSTALW_TAR_FILENAME"], vigor_dirs["CLUSTALW_DIR"], "deb")
	if not _path_exists(os.path.join(vigor_dirs["EXE_DIR"], "clustalw")):
		sudo("ln -sf %s %s" % (os.path.join(vigor_dirs["CLUSTALW_DIR"], vigor_names["CLUSTALW_NAME"], "clustalw"), vigor_dirs["EXE_DIR"]))


# VICVB - install methods

def install_vicvb(env):
	try:
		_initialize_env("vicvb")
		
		_apt_get_install("libperlio-gzip-perl")
		_apt_get_install("liblocal-lib-perl")
		
		tbl2asn_download_dir = "/usr/local/tbl2asn_download"
		tbl2asn_dir = "/usr/local/bin"
		if _path_exists(os.path.join(tbl2asn_dir,"tbl2asn")):
			sudo("mv %s/tbl2asn %s/tbl2asn_pre_VCR" % (tbl2asn_dir,tbl2asn_dir))
		_add_package("ftp://ftp.ncbi.nih.gov/toolbox/ncbi_tools/converters/by_program/tbl2asn","linux64.tbl2asn.gz",tbl2asn_download_dir,"gzip")
		sudo("chmod 777 %s/linux64.tbl2asn" % tbl2asn_download_dir)
		sudo("mv %s/linux64.tbl2asn %s/tbl2asn" % (tbl2asn_download_dir,tbl2asn_dir))
		_remove_dir(tbl2asn_download_dir)
		
		with cd("~"):
			sudo("git clone git://github.com/JCVI-Cloud/VICVB.git")
		with cd("~/VICVB"):
			sudo("lib/VICVB/data/install/install_to_dir_full.sh %s /mnt/galaxyTools/galaxy-central /" % (env.VICVB_LOCAL_DIR))
	finally:
		disconnect_all()

def install_vicvb_cleanall(env):
	try:
		_initialize_env("vicvb")
		_remove_dir(env.VICVB_LOCAL_DIR)
		_remove_dir(env.VICVB_GALAXY_DIR)
		with cd ("~"):
			sudo("rm -fr ~/VICVB")
		print("VICVB Removed\n")
	finally:
		disconnect_all()


# Common methods

def _initialize_env(pipeline):
	if pipeline == "viral":
		env.VIRAL_ROOT_DIR = "/usr/local/VHTNGS"
		if not _path_exists(env.VIRAL_ROOT_DIR):
			sudo("mkdir -p %s" % env.VIRAL_ROOT_DIR)
	elif pipeline == "vigor":
		env.VIGOR_ROOT_DIR = "/usr/local/VIGOR"
		if not _path_exists(env.VIGOR_ROOT_DIR):
			sudo("mkdir -p %s" % env.VIGOR_ROOT_DIR)
		env.VIGOR_SCRATCH_DIR = "/usr/local/scratch/vigor"
		if not _path_exists(env.VIGOR_SCRATCH_DIR):
			sudo("mkdir -p %s" % env.VIGOR_SCRATCH_DIR)
			sudo("find %s -type f -exec chmod 666 {} \;" % env.VIGOR_SCRATCH_DIR)
			sudo("find %s -type d -exec chmod 777 {} \;" % env.VIGOR_SCRATCH_DIR)
	else:
		env.VICVB_LOCAL_DIR = "/usr/local/VICVB";
		env.VICVB_GALAXY_DIR = "/mnt/galaxyTools/galaxy-central/static/vicvb";

def _add_package(download_url, filename, install_dir, type):
	if not _path_is_dir(install_dir):
		sudo("mkdir -p %s" % install_dir)
	with cd(install_dir):
		if not _path_exists(os.path.join(install_dir, filename)):
			sudo("""wget --no-host-directories --cut-dirs=1 --directory-prefix=%s %s/%s""" % (install_dir, download_url, filename))
			if type == "tar":
				sudo("tar xvfz %s" % filename)
			elif type == "bz2":
				sudo("tar xfj %s" % filename)
			elif type == "gzip":
				sudo("gunzip %s" % filename)
			else: 
				sudo("dpkg -x %s %s" % (filename,install_dir))
				sudo("mkdir %s/%s" % (install_dir, vigor_names["CLUSTALW_NAME"]))
				sudo("cp %s/usr/bin/* %s/%s" % (install_dir,install_dir,vigor_names["CLUSTALW_NAME"]))
	sudo("chown -R %s:%s %s" % (env.user, env.user, install_dir))
	sudo("find %s -type d -exec chmod 755 {} \;" % install_dir)

def _remove_dir(dirspec):
	if _path_is_dir(dirspec):
		_unlock_dir(dirspec)
		sudo("rm -rf %s" % dirspec)
	else:
		print("DEBUG: _remove_dir[%s] -- NOT FOUND" % dirspec)

def _unlock_dir(dirspec):
	with settings(hide("running","stdout")):
		sudo("find %s -type d -exec chmod 755 {} \;" % dirspec)
		sudo("find %s -type d -exec chmod g+s {} \;" % dirspec)
		sudo("find %s -type f -exec chmod 644 {} \;" % dirspec)

def _apt_get_install(tool):
	sudo("apt-get -q -y --force-yes install %s" % tool)

def _path_exists(path):
	found = False
	with settings(hide("running","stdout")):
		result = sudo("test -e '%s' || echo 'FALSE'" % path)
	if result != "FALSE": found = True
	return found

def _path_is_dir(path):
	found = False
	with settings(hide("running","stdout")):
		result = sudo("test -d '%s' || echo 'FALSE'" % path)
	if result != "FALSE": found = True
	return found

def _set_pre_VCR(filename,user,group):
	sudo("cp %s %s_pre_VCR" %(filename,filename))
	sudo("chown %s:%s %s_pre_VCR" % (user,group,filename))

def _get_file_string(filename,directory):
	fh = open("%s/%s" % (directory,filename))
	string = mmap.mmap(fh.fileno(),0,access=mmap.ACCESS_READ)
	fh.close()
	return string
