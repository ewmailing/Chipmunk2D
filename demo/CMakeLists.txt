find_package(OpenGL REQUIRED)

# Quick and dirty package searching.
# Will probably only work on Unixes.
# TODO need to fix this up eventually.
if(APPLE)
  if(NOT IOS)
    FIND_LIBRARY(GLFW_LIBRARIES glfw ${CMAKE_SOURCE_DIR}/xcode/libglfw/lib)
    FIND_LIBRARY(GLEW_LIBRARIES GLEW ${CMAKE_SOURCE_DIR}/xcode/libGLEW/lib)
    FIND_PATH(GLFW_INCLUDE_DIR GL/glfw.h ${CMAKE_SOURCE_DIR}/xcode/libglfw/include)
    FIND_PATH(GLEW_INCLUDE_DIR GL/glew.h ${CMAKE_SOURCE_DIR}/xcode/libGLEW/include)
  endif()
else()
  FIND_LIBRARY(GLFW_LIBRARIES glfw /usr/lib)
  FIND_LIBRARY(GLEW_LIBRARIES GLEW /usr/lib)
  FIND_PATH(GLFW_INCLUDE_DIR GL/glfw.h /usr/include/GL)
  FIND_PATH(GLEW_INCLUDE_DIR GL/glew.h /usr/include/GL)
endif()

set(chipmunk_demos_include_dirs
  ${chipmunk_SOURCE_DIR}/include
  ${GLFW_INCLUDE_DIR}
  ${GLEW_INCLUDE_DIR}
  ${OPENGL_INCLUDE_DIR}
)

set(chipmunk_demos_libraries
  chipmunk_static
  ${GLFW_LIBRARIES}
  ${GLEW_LIBRARIES}
  ${OPENGL_LIBRARIES}
)

if(NOT MSVC)
  list(APPEND chipmunk_demos_libraries m)
endif(NOT MSVC)

if(APPLE)
  if(IOS)
  else()
    FIND_LIBRARY(APPLE_COCOA_LIBRARY "Cocoa")	
	FIND_LIBRARY(APPLE_IOKIT_LIBRARY "IOKit")	
    list(APPEND chipmunk_demos_libraries ${APPLE_COCOA_LIBRARY} ${APPLE_IOKIT_LIBRARY})    
  endif()
endif()
file(GLOB chipmunk_demos_source_files "*.c")

include_directories(${chipmunk_demos_include_dirs})
add_executable(chipmunk_demos MACOSX_BUNDLE ${chipmunk_demos_source_files})
target_link_libraries(chipmunk_demos ${chipmunk_demos_libraries})

# Tell MSVC to compile the code as C++.
if(MSVC)
  set_source_files_properties(${chipmunk_demos_source_files} PROPERTIES LANGUAGE CXX)
  set_target_properties(chipmunk_demos PROPERTIES LINKER_LANGUAGE CXX)
endif(MSVC)

if(INSTALL_DEMOS)
  install(TARGETS chipmunk_demos RUNTIME DESTINATION bin)
endif(INSTALL_DEMOS)
