# Prevent multiple includes
if (TARGET libtint)
	return()
endif()

include(FetchContent)

FetchContent_Declare(
	tint

	# Manual download mode, even shallower than GIT_SHALLOW ON
	DOWNLOAD_COMMAND
		cd ${FETCHCONTENT_BASE_DIR}/tint-src &&
		git init &&
		git remote add origin https://dawn.googlesource.com/tint &&
		git fetch --depth 1 origin 941e2eb2b45a4c390cdf077f6ed1f272dc235d5f &&
		git checkout FETCH_HEAD
)

FetchContent_GetProperties(tint)
if (NOT tint_POPULATED)
	FetchContent_Populate(tint)

	find_package(PythonInterp 3 REQUIRED)

	message(STATUS "Running fetch_tint_dependencies:")
	execute_process(
		COMMAND ${PYTHON_EXECUTABLE} "${CMAKE_CURRENT_SOURCE_DIR}/tools/fetch_dawn_dependencies.py"
		WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/_deps/tint-src"
	)

	configure_file("${CMAKE_CURRENT_SOURCE_DIR}/tools/web_build_fix.patch" "${CMAKE_BINARY_DIR}/_deps/tint-src/web_build_fix.patch" COPYONLY)

	message(STATUS "Applying Tint patch...")

	execute_process(
		COMMAND cmd /C cd ${CMAKE_BINARY_DIR}/_deps/tint-src && git apply web_build_fix.patch
	)

	# Disable unneeded parts
	set(TINT_BUILD_SAMPLES OFF)
	set(TINT_BUILD_DOCS OFF)
	set(TINT_BUILD_TESTS OFF)
	set(TINT_BUILD_FUZZERS OFF)
	set(TINT_BUILD_SPIRV_TOOLS_FUZZER OFF)
	set(TINT_BUILD_AST_FUZZER OFF)
	set(TINT_BUILD_REGEX_FUZZER OFF)
	set(TINT_BUILD_BENCHMARKS OFF)
	set(TINT_BUILD_TESTS OFF)
	set(TINT_BUILD_AS_OTHER_OS OFF)
	set(TINT_BUILD_REMOTE_COMPILE OFF)
	set(TINT_BUILD_GLSL_WRITER OFF)
	set(TINT_BUILD_HLSL_WRITER OFF)
	set(TINT_BUILD_MSL_WRITER OFF)
	set(TINT_BUILD_WGSL_WRITER ON)
	set(TINT_BUILD_WGSL_READER ON)
	set(TINT_BUILD_SPV_READER OFF)
	set(TINT_BUILD_SPV_WRITER OFF)
	set(TINT_BUILD_CMD_TOOLS OFF)

	add_subdirectory(${tint_SOURCE_DIR} ${tint_BINARY_DIR})
endif ()
