cmake_minimum_required(VERSION 3.13)
project(webgpu-backend-dawn VERSION 1.0.0)

add_library(webgpu INTERFACE)

if (EMSCRIPTEN)

	message(STATUS "Downloading Tint...")

	include(cmake/FetchTint.cmake)

	target_link_libraries(webgpu INTERFACE tint_lang_wgsl_reader)
	target_include_directories(webgpu INTERFACE
		"${CMAKE_CURRENT_SOURCE_DIR}/include-emscripten"
		"${CMAKE_BINARY_DIR}/_deps/tint-src/include"
		"${CMAKE_BINARY_DIR}/_deps/tint-src"
	)

	# This is used to advertise the flavor of WebGPU that this zip provides
	target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_EMSCRIPTEN)

else (EMSCRIPTEN)

	message(STATUS "Using Dawn backend for WebGPU")
	message(STATUS "Downloading Dawn...")

	include(cmake/FetchDawn.cmake)

	target_link_libraries(webgpu INTERFACE webgpu_dawn libtint)
	target_include_directories(webgpu INTERFACE
		"${CMAKE_CURRENT_SOURCE_DIR}/include"
		"${CMAKE_BINARY_DIR}/_deps/dawn-src/include"
	)

	# This is used to advertise the flavor of WebGPU that this zip provides
	target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_DAWN)

endif (EMSCRIPTEN)

# Does nothing, as this dawn-based distribution of WebGPU is statically linked
function(target_copy_webgpu_binaries Target)
endfunction()
