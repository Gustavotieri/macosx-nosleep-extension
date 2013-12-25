CONFIG=Release

BUILDDIR=DerivedData/NoSleep/Build/Products/$(CONFIG)

SUDO=sudo
KEXTSTAT=/usr/sbin/kextstat
KEXTUNLOAD=/sbin/kextunload
KEXTUTIL=/usr/bin/kextutil

.PHONY: all
all: delivery

.PHONY: package
package: binaries
	packagesbuild Installer/NoSleepPkg.pkgproj

.PHONY: binaries
binaries:
	xcodebuild -parallelizeTargets -project NoSleep/NoSleep.xcodeproj -alltargets -configuration $(CONFIG)

.PHONY: clean
clean:
	/bin/rm -rf Delivery NoSleep/build

.PHONY: delivery
delivery:
	$(MAKE) clean
	$(MAKE) package
	mkdir Delivery
	cat Installer/Scripts/Common.sh > Delivery/Uninstall.command
	cat Installer/Scripts/Uninstall_1.3.1.sh >> Delivery/Uninstall.command
	echo >> Delivery/Uninstall.command
	cat Installer/Scripts/Uninstall_Cli_1.3.0.sh >> Delivery/Uninstall.command
	chmod +x Delivery/Uninstall.command
	cp -r Installer/NoSleep.mpkg Delivery/

.PHONY: dmg
dmg: delivery
	if [ -e DMG ]; then rm -rf DMG; fi
	mkdir -p DMG
	./Utilities/create-dmg \
		--window-size 480 300 \
		--icon-size 96 \
		--volname "NoSleep Extension" \
		--icon "NoSleep.mpkg" 160 130 \
		--icon "Uninstall.command" 320 130 \
		DMG/NoSleep.dmg \
		Delivery
	cp DMG/NoSleep.dmg Delivery
	rm -rf DMG

.PHONY: dk, dkc
dkc:
	$(SUDO) $(KEXTUNLOAD) -b com.protech.NoSleep
	$(SUDO) rm -rf $(BUILDDIR)/NoSleep.kext
dk:
	#$(MAKE) clean
	#CONFIG=Debug $(MAKE) all
	#if [ "$(KEXTSTAT)|grep NoSleep" ]; then $(SUDO) $(KEXTUNLOAD) -b com.protech.NoSleep; fi
	$(SUDO) chown -R root:wheel $(BUILDDIR)/NoSleep.kext
	$(SUDO) $(KEXTUTIL) $(BUILDDIR)/NoSleep.kext

