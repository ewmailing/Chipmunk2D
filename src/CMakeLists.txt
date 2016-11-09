file(GLOB chipmunk_source_files "*.c")
file(GLOB chipmunk_public_header "${chipmunk_SOURCE_DIR}/include/chipmunk/*.h")

include_directories(${chipmunk_SOURCE_DIR}/include)

set(CHIPMUNK_VERSION_MAJOR 7)
set(CHIPMUNK_VERSION_MINOR 0)
set(CHIPMUNK_VERSION_PATCH 0)
set(CHIPMUNK_VERSION "${CHIPMUNK_VERSION_MAJOR}.${CHIPMUNK_VERSION_MINOR}.${CHIPMUNK_VERSION_PATCH}")
message("Configuring Chipmunk2D version ${CHIPMUNK_VERSION}")

if(BUILD_SHARED)
  set(CMAKE_MACOSX_RPATH 1)
  # when building, don't use the install RPATH already
  # (but later on when installing)
  set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE) 
  # add the automatically determined parts of the RPATH
  # which point to directories outside the build tree to the install RPATH
  set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)	

  if(MSVC)
    # Windows dll's must explicitly export symbols. This information is not embedded in headers, so we need a .def file.
    list(APPEND chipmunk_source_files "${CMAKE_SOURCE_DIR}/msvc/vc13/chipmunk/chipmunk.def")
    add_definitions(-DCRT_SECURE_NO_WARNINGS)
  endif(MSVC)

  if(ANDROID)
    # At this point in time, all Android ARMv7 devices ship with NEON.
    # Android doesn't automatically set any #defines for us because they wanted us to do a runtime check.
    # This is pointless now, so just turn it on.
    if(NEON OR VFPV3 OR ARMEABI_V7A)
	    add_definitions(-D__ARM_NEON__)
    endif()
  endif(ANDROID)
  
  add_library(chipmunk SHARED
    ${chipmunk_source_files}
    ${chipmunk_public_header}
  )

  # Legacy option for MSVC to compile the code as C++.
  if(BUILD_AS_CPP)
    set_source_files_properties(${chipmunk_source_files} PROPERTIES LANGUAGE CXX)
    set_target_properties(chipmunk PROPERTIES LINKER_LANGUAGE CXX)
  endif(BUILD_AS_CPP)
  # set the lib's version number
  # But avoid on Android because symlinks to version numbered .so's don't work with Android's Java-side loadLibrary.
  if(NOT ANDROID)
    set_target_properties(chipmunk PROPERTIES
      SOVERSION ${CHIPMUNK_VERSION_MAJOR}
# Blurrr HOTFIX: The soname is written as libchipmunk.so.7, but CMake makes this a symlink to libchipmunk.so.7.0.0 for the real binary which screws up analysis when looking at the ldd/objdump.
# The easiest fix is to make them the same or disable versioing all together.
	  # VERSION ${CHIPMUNK_VERSION})
      VERSION ${CHIPMUNK_VERSION_MAJOR})
  endif(NOT ANDROID)
  if(ANDROID OR UNIX)
	  # need to explicitly link to the math library because the CMake/Android toolchains may not do it automatically
	  target_link_libraries(chipmunk m)
  endif(ANDROID OR UNIX)
  install(TARGETS chipmunk RUNTIME DESTINATION ${BIN_INSTALL_DIR}
                           LIBRARY DESTINATION ${LIB_INSTALL_DIR}
                           ARCHIVE DESTINATION ${LIB_INSTALL_DIR})
endif(BUILD_SHARED)

if(BUILD_SHARED AND BUILD_FRAMEWORK)
  set_target_properties(chipmunk PROPERTIES
		FRAMEWORK TRUE
		FRAMEWORK_VERSION "A"
		#  PRIVATE_HEADER "fooPrivate.h;fooBoth.h"
		PUBLIC_HEADER "${chipmunk_public_header}"
#		RESOURCE "${RESOURCE_FILES}"
		# INSTALL_NAME_DIR ${CMAKE_FRAMEWORK_INSTALL_NAME_DIR}
		# BUILD_WITH_INSTALL_RPATH ${CMAKE_BUILD_WITH_INSTALL_RPATH} 
#		VERSION ${LUA_VERSION}
#		SOVERSION ${LUA_COMPATIBILITY_VERSION}
		COMPILE_FLAGS "${BLURRR_C_FLAGS}"
	)
	set(MACOSX_FRAMEWORK_IDENTIFIER "com.howlingmoonsoftware.chipmunk")

endif(BUILD_SHARED AND BUILD_FRAMEWORK)

if(BUILD_STATIC)
  add_library(chipmunk_static STATIC
    ${chipmunk_source_files}
  )
  # Tell MSVC to compile the code as C++.
  if(MSVC)
    set_source_files_properties(${chipmunk_source_files} PROPERTIES LANGUAGE CXX)
    set_target_properties(chipmunk_static PROPERTIES LINKER_LANGUAGE CXX)
  endif(MSVC)
  # Sets chipmunk_static to output "libchipmunk.a" not "libchipmunk_static.a"
  set_target_properties(chipmunk_static PROPERTIES OUTPUT_NAME chipmunk)
  if(INSTALL_STATIC)
    install(TARGETS chipmunk_static ARCHIVE DESTINATION ${LIB_INSTALL_DIR})
  endif(INSTALL_STATIC)
endif(BUILD_STATIC)

IF(APPLE)
  include(XcodeDefaults)
  if(BUILD_SHARED)
    BLURRR_CONFIGURE_XCODE_DEFAULTS(chipmunk)
  endif(BUILD_SHARED)
  if(BUILD_STATIC)
    BLURRR_CONFIGURE_XCODE_DEFAULTS(chipmunk_static)
  endif(BUILD_STATIC)
ENDIF()


if(BUILD_SHARED OR INSTALL_STATIC)
  if(BUILD_FRAMEWORK)
    INSTALL(TARGETS
      chipmunk
      FRAMEWORK DESTINATION Frameworks
    )
  else()
    install(FILES ${chipmunk_public_header} DESTINATION include/chipmunk)
    install(FILES ${chipmunk_constraint_header} DESTINATION include/chipmunk/constraints)
  endif()
endif(BUILD_SHARED OR INSTALL_STATIC)
