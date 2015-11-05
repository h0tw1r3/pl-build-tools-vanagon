component "yaml-cpp" do |pkg, settings, platform|
  pkg.version "0.5.1"
  pkg.md5sum "0fa47a5ed8fedefab766592785c85ee7"
  pkg.url "http://buildsources.delivery.puppetlabs.net/#{pkg.get_name}-#{pkg.get_version}.tar.gz"

  cmake = "#{settings[:bindir]}/cmake"

  # This is pretty horrible.  But so is package management on OSX.
  if platform.is_osx?
    pkg.build_requires "pl-gcc-4.8.2"
    pkg.build_requires "pl-cmake-3.2.3"
    pkg.build_requires "pl-boost-1.58.0"
  elsif platform.is_solaris?
    if platform.os_version == "10"
      pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-gcc-4.8.2.#{platform.architecture}.pkg.gz"
      pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-binutils-2.25.#{platform.architecture}.pkg.gz"
      pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-boost-1.58.0-1.#{platform.architecture}.pkg.gz"
      pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/solaris/10/pl-cmake-3.2.3-2.i386.pkg.gz"
    elsif platform.os_version == "11"
      pkg.build_requires "pl-binutils-#{platform.architecture}"
      pkg.build_requires "pl-gcc-#{platform.architecture}"
      pkg.build_requires "pl-boost-#{platform.architecture}"
      pkg.build_requires "pl-cmake"
    end
    # We always use the i386 build of cmake, even on sparc
    cmake = "#{settings[:basedir]}/i386-pc-solaris2.#{platform.os_version}/bin/cmake"
  elsif platform.is_aix?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-gcc-5.2.0-1.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-boost-1.58.0-1.aix#{platform.os_version}.ppc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/aix/#{platform.os_version}/ppc/pl-cmake-3.2.3-2.aix#{platform.os_version}.ppc.rpm"
  elsif platform.is_huaweios?
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/HuaweiOS/#{platform.os_version}/ppce500mc/pl-gcc-4.8.2-1.huaweios6.ppce500mc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/HuaweiOS/#{platform.os_version}/ppce500mc/pl-cmake-3.2.3-1.huaweios6.ppce500mc.rpm"
    pkg.build_requires "http://pl-build-tools.delivery.puppetlabs.net/HuaweiOS/#{platform.os_version}/ppce500mc/pl-boost-1.58.0-1.huaweios6.ppce500mc.rpm"
  else
    pkg.build_requires "pl-gcc"
    pkg.build_requires "make"
    pkg.build_requires "pl-cmake"
    pkg.build_requires "pl-boost"
  end

  if platform.name =~ /el-4/
    pkg.build_requires "pl-tar"
  end

  # Different toolchains for different target platforms.
  if platform.is_osx?
    toolchain = "pl-build-toolchain-darwin"
  else
    toolchain = "pl-build-toolchain"
  end

  pkg.build do
    [ "rm -rf build-shared",
      "mkdir build-shared",
      "cd build-shared",
      "#{cmake} \
    -DCMAKE_TOOLCHAIN_FILE=#{settings[:prefix]}/#{toolchain}.cmake \
    -DCMAKE_INSTALL_PREFIX=#{settings[:prefix]} \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DYAML_CPP_BUILD_TOOLS=0 \
    -DBUILD_SHARED_LIBS=ON \
    .. ",
      "#{platform[:make]} VERBOSE=1 -j$(shell expr $(shell #{platform[:num_cores]}) + 1)",
      "cd ../",
      "rm -rf build-static",
      "mkdir build-static",
      "cd build-static", "#{cmake} \
    -DCMAKE_TOOLCHAIN_FILE=#{settings[:prefix]}/#{toolchain}.cmake \
    -DCMAKE_INSTALL_PREFIX=#{settings[:prefix]} \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DYAML_CPP_BUILD_TOOLS=0 \
    -DBUILD_SHARED_LIBS=OFF \
    ..",
      "#{platform[:make]} VERBOSE=1 -j$(shell expr $(shell #{platform[:num_cores]}) + 1)"
    ]
  end

  pkg.install do
    [ "cd build-shared",
      "#{platform[:make]} install",
      "cd ../build-static",
      "#{platform[:make]} install"
    ]
  end

end
