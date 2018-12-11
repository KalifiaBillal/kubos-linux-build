###############################################
#
# Kubos MAI400 Service
#
###############################################

KUBOS_MAI400_POST_BUILD_HOOKS += MAI400_BUILD_CMDS
KUBOS_MAI400_POST_INSTALL_TARGET_HOOKS += MAI400_INSTALL_TARGET_CMDS
KUBOS_MAI400_POST_INSTALL_TARGET_HOOKS += MAI400_INSTALL_INIT_SYSV

define MAI400_BUILD_CMDS
	cd $(BUILD_DIR)/kubos-$(KUBOS_VERSION)/services/mai400-service && \
	PATH=$(PATH):~/.cargo/bin:/usr/bin/iobc_toolchain/usr/bin && \
	CC=$(TARGET_CC) cargo build --target $(CARGO_TARGET) --release
endef

# Install the application into the rootfs file system
define MAI400_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/sbin
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/kubos-$(KUBOS_VERSION)/$(CARGO_OUTPUT_DIR)/mai400-service \
		$(TARGET_DIR)/usr/sbin
		
    echo 'CHECK PROCESS kubos-mai400 PIDFILE /var/run/mai400-service.pid' > $(TARGET_DIR)/etc/monit.d/kubos-mai400.cfg
    echo '    START PROGRAM = "/etc/init.d/S${BR2_KUBOS_MAI400_INIT_LVL}kubos-mai400 start"' >> $(TARGET_DIR)/etc/monit.d/kubos-mai400.cfg 
    echo '    IF ${BR2_KUBOS_MAI400_RESTART_COUNT} RESTART WITHIN ${BR2_KUBOS_MAI400_RESTART_CYCLES} CYCLES THEN TIMEOUT' \
    >> $(TARGET_DIR)/etc/monit.d/kubos-mai400.cfg
endef

# Install the init script
define MAI400_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_KUBOS_LINUX_PATH)/package/kubos/kubos-mai400/kubos-mai400 \
	    $(TARGET_DIR)/etc/init.d/S$(BR2_KUBOS_MAI400_INIT_LVL)kubos-mai400
endef

$(eval $(virtual-package))