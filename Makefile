FILES_TO_RPM = cmd/revad/revad cmd/revad/revad-ceph
SPECFILE = $(shell find . -maxdepth 1 -type f -name *.spec)
PACKAGE  = $(shell awk '$$1 == "Name:"     { print $$2 }' $(SPECFILE) )
VERSION  = $(shell awk '$$1 == "Version:"  { print $$2 }' $(SPECFILE) )
RELEASE  = $(shell awk '$$1 == "Release:"  { print $$2 }' $(SPECFILE) )
rpmbuild = ${shell pwd}/build

clean:
	@rm -rf $(PACKAGE)-$(VERSION)
	@rm -rf $(rpmbuild)

rpmdefines=--define='_topdir ${rpmbuild}' \
        --define='_sourcedir %{_topdir}/SOURCES' \
        --define='_builddir %{_topdir}/BUILD' \
        --define='_srcrpmdir %{_topdir}/SRPMS' \
        --define='_rpmdir %{_topdir}/RPMS'

dist: clean
	make revad-ceph
	@mv cmd/revad/revad cmd/revad/revad-ceph
	make revad
	@mkdir -p $(PACKAGE)-$(VERSION)
	@cp -r $(FILES_TO_RPM) $(PACKAGE)-$(VERSION)
	tar cpfz ./$(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-$(VERSION)

prepare: dist
	@mkdir -p $(rpmbuild)/RPMS/x86_64
	@mkdir -p $(rpmbuild)/SRPMS/
	@mkdir -p $(rpmbuild)/SPECS/
	@mkdir -p $(rpmbuild)/SOURCES/
	@mkdir -p $(rpmbuild)/BUILD/
	@mv $(PACKAGE)-$(VERSION).tar.gz $(rpmbuild)/SOURCES 
	@cp $(SPECFILE) $(rpmbuild)/SOURCES 

srpm: prepare $(SPECFILE)
	rpmbuild --nodeps -bs $(rpmdefines) $(SPECFILE)
	cp $(rpmbuild)/SRPMS/* .

rpm: srpm
	rpmbuild --nodeps -bb $(rpmdefines) $(SPECFILE)
	cp $(rpmbuild)/RPMS/x86_64/* .
