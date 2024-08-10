cmake_minimum_required(VERSION 3.13)
project(webgpu-backend-dawn VERSION 1.0.0)

add_library(webgpu INTERFACE)

if(POLICY CMP0135)
  cmake_policy(SET CMP0135 NEW)
endif()

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

	string(TOUPPER ${DAWN_BUILD} DAWN_BUILD_U)

	if (DAWN_BUILD_U STREQUAL "SRC")

		message(STATUS "Downloading Dawn source...")

		include(cmake/FetchDawn.cmake)

		target_link_libraries(webgpu INTERFACE webgpu_dawn libtint)

	elseif (DAWN_BUILD_U STREQUAL "STATIC")

		message(STATUS "Downloading Dawn static...")

		FetchContent_Declare(
			dawn
			URL https://github.com/upf-gti/dawn/releases/download/v1.1/dawn_static.7z
			# DOWNLOAD_DIR ${WGPU_DIR_LIBS}/dawn_static
		)

		FetchContent_Populate(dawn)

		include(cmake/FetchTint.cmake)

		# target_link_libraries(webgpu INTERFACE tint_lang_wgsl_reader)
		target_include_directories(webgpu INTERFACE
			"${CMAKE_BINARY_DIR}/_deps/tint-src/include"
			"${CMAKE_BINARY_DIR}/_deps/tint-src"
		)

		# target_link_libraries(webgpu INTERFACE dxguid.lib)

		target_link_libraries(webgpu INTERFACE
			debug "${CMAKE_BINARY_DIR}/_deps/dawn-src/lib/dawn_static_debug.lib"
			optimized "${CMAKE_BINARY_DIR}/_deps/dawn-src/lib/dawn_static_release.lib"
		)

	else()
		message(FATAL_ERROR "Invalid value for DAWN_BUILD: possible values are STATIC and SRC, but '${DAWN_BUILD_U}' was provided.")
	endif()

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
