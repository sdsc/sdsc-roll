-include $(shell ${ROCKSROOT}/bin/arch).mk
-include $(shell ${ROCKSROOT}/bin/os).mk

default:
	@echo "copyright|rpm|pkg|clean"

copyright rpm pkg clean::
	for i in $(SRCDIRS); do \
	  (cd $$i && $(MAKE) $@) || exit 2; \
	done
