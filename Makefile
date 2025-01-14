BOX_VERSION ?= $(shell cat VERSION)
BOX_SUFFIX := -$(BOX_VERSION).box
BUILDER_TYPES ?= vmware virtualbox parallels
TEMPLATE_FILENAMES := $(wildcard *.json)
BOX_NAMES := $(basename $(TEMPLATE_FILENAMES))
BOX_FILENAMES := $(TEMPLATE_FILENAMES:.json=$(BOX_SUFFIX))

VMWARE_BOX_DIR ?= box/vmware
VMWARE_TEMPLATE_FILENAMES = $(TEMPLATE_FILENAMES)
VMWARE_BOX_FILENAMES := $(VMWARE_TEMPLATE_FILENAMES:.json=$(BOX_SUFFIX))
VMWARE_BOX_FILES := $(foreach box_filename, $(VMWARE_BOX_FILENAMES), $(VMWARE_BOX_DIR)/$(box_filename))

VIRTUALBOX_BOX_DIR ?= box/virtualbox
VIRTUALBOX_TEMPLATE_FILENAMES = $(TEMPLATE_FILENAMES)
VIRTUALBOX_BOX_FILENAMES := $(VIRTUALBOX_TEMPLATE_FILENAMES:.json=$(BOX_SUFFIX))
VIRTUALBOX_BOX_FILES := $(foreach box_filename, $(VIRTUALBOX_BOX_FILENAMES), $(VIRTUALBOX_BOX_DIR)/$(box_filename))

PARALLELS_BOX_DIR ?= box/parallels
PARALLELS_TEMPLATE_FILENAMES = $(TEMPLATE_FILENAMES)
PARALLELS_BOX_FILENAMES := $(PARALLELS_TEMPLATE_FILENAMES:.json=$(BOX_SUFFIX))
PARALLELS_BOX_FILES := $(foreach box_filename, $(PARALLELS_BOX_FILENAMES), $(PARALLELS_BOX_DIR)/$(box_filename))


BOX_FILES := $(VMWARE_BOX_FILES) $(VIRTUALBOX_BOX_FILES) $(PARALLELS_BOX_FILES)

box/vmware/%$(BOX_SUFFIX) box/virtualbox/%$(BOX_SUFFIX) box/parallels/%$(BOX_SUFFIX): %.json
	bin/box build $<

.PHONY: all clean test deliver test_cloud test_vmware test_virtualbox test_parallels test_cloud_vmware test_cloud_virtualbox test_cloud_parallels

all: build test deliver

build: $(BOX_FILES)

test: test_vmware test_virtualbox test_parallels

test_vmware: $(VMWARE_BOX_FILES)
	@for vmware_box_file in $(VMWARE_BOX_FILES) ; do \
		echo Checking $$vmware_box_file ; \
		bin/box test $$vmware_box_file vmware ; \
	done

test_virtualbox: $(VIRTUALBOX_BOX_FILES)
	@for virtualbox_box_file in $(VIRTUALBOX_BOX_FILES) ; do \
		echo Checking $$virtualbox_box_file ; \
		bin/box test $$virtualbox_box_file virtualbox ; \
	done

test_parallels: $(PARALLELS_BOX_FILES)
	@for parallels_box_file in $(PARALLELS_BOX_FILES) ; do \
		echo Checking $$parallels_box_file ; \
		bin/box test $$parallels_box_file parallels ; \
	done

test_cloud: test_cloud_vmware test_cloud_virtualbox test_cloud_parallels

test_cloud_vmware:
	@for box_name in $(BOX_NAMES) ; do \
		echo Checking $$box_name ; \
		bin/test-cloud-box fasmat/$$box_name vmware $(BOX_VERSION) ; \
	done

test_cloud_virtualbox:
	@for box_name in $(BOX_NAMES) ; do \
		echo Checking $$box_name ; \
		bin/test-cloud-box fasmat/$$box_name virtualbox $(BOX_VERSION) ; \
	done

test_cloud_parallels:
	@for box_name in $(BOX_NAMES) ; do \
		echo Checking $$box_name ; \
		bin/test-cloud-box fasmat/$$box_name parallels $(BOX_VERSION) ; \
	done

deliver:
	@for box_name in $(BOX_NAMES) ; do \
		echo Uploading $$box_name to Atlas ; \
		bin/register_cloud.sh $$box_name $(BOX_SUFFIX) $(BOX_VERSION) ; \
	done

clean:
	@for builder in $(BUILDER_TYPES) ; do \
		echo Deleting output-*-$$builder-iso ; \
		echo rm -rf output-*-$$builder-iso ; \
	done
	@for builder in $(BUILDER_TYPES) ; do \
		if test -d box/$$builder ; then \
			echo Deleting box/$$builder/*.box ; \
			find box/$$builder -maxdepth 1 -type f -name "*.box" ! -name .gitignore -exec rm '{}' \; ; \
		fi ; \
	done

