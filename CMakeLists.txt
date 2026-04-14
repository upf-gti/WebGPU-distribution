cmake_minimum_required(VERSION 3.22)
project(webgpu-backend-dawn VERSION 1.0.0)

add_library(webgpu INTERFACE)

if(POLICY CMP0135)
  cmake_policy(SET CMP0135 NEW)
endif()

if (EMSCRIPTEN)

	message(STATUS "Downloading Dawn source...")

	include(cmake/FetchDawn.cmake)

	# TODO: this is a hack, emdawnwebgpu_c is including files before they are generated
	# create a dummy file until it's overwritten
	file(TOUCH ${CMAKE_BINARY_DIR}/_deps/dawn-build/gen/src/emdawnwebgpu/include/webgpu/webgpu.h "")

	target_link_libraries(webgpu INTERFACE emdawnwebgpu_c)
	target_link_libraries(webgpu INTERFACE tint_lang_wgsl_reader tint_lang_wgsl_inspector)

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
			URL https://github.com/upf-gti/dawn/releases/download/v1.5/dawn_static.7z
			# DOWNLOAD_DIR ${WGPU_DIR_LIBS}/dawn_static
		)

		FetchContent_MakeAvailable(dawn)

		# target_link_libraries(webgpu INTERFACE tint_lang_wgsl_reader)
		target_include_directories(webgpu SYSTEM INTERFACE
			"${CMAKE_BINARY_DIR}/_deps/dawn-src/include"
			"${CMAKE_BINARY_DIR}/_deps/dawn-src/include/tint"
		)

		if (WIN32)
			target_link_libraries(webgpu INTERFACE dxguid.lib)
		endif()

		target_link_libraries(webgpu INTERFACE
			debug "${CMAKE_BINARY_DIR}/_deps/dawn-src/lib/webgpu_dawn_debug.lib"
			optimized "${CMAKE_BINARY_DIR}/_deps/dawn-src/lib/webgpu_dawn_release.lib"
		)

		set_target_properties(webgpu PROPERTIES LINK_FLAGS "/ignore:4099")

	else()
		message(FATAL_ERROR "Invalid value for DAWN_BUILD: possible values are STATIC and SRC, but '${DAWN_BUILD_U}' was provided.")
	endif()

	target_include_directories(webgpu SYSTEM INTERFACE
		"${CMAKE_BINARY_DIR}/_deps/dawn-src/include"
	)

	# This is used to advertise the flavor of WebGPU that this zip provides
	target_compile_definitions(webgpu INTERFACE WEBGPU_BACKEND_DAWN)

endif (EMSCRIPTEN)

