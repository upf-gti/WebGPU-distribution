# Prevent multiple includes
if (TARGET dawn_native)
	return()
endif()

include(FetchContent)

FetchContent_Declare(
	dawn
	#GIT_REPOSITORY https://dawn.googlesource.com/dawn
	#GIT_TAG        chromium/5715
	#GIT_SHALLOW ON

	# Manual download mode, even shallower than GIT_SHALLOW ON
	DOWNLOAD_COMMAND
		cd ${FETCHCONTENT_BASE_DIR}/dawn-src &&
		git init &&
		git pull --depth=1 https://github.com/upf-gti/dawn openxr-dev &&
		git reset --hard FETCH_HEAD
)

FetchContent_GetProperties(dawn)
if (NOT dawn_POPULATED)
	FetchContent_Populate(dawn)

	set(DAWN_FETCH_DEPENDENCIES ON)

	set(USE_METAL  OFF)
	set(USE_VULKAN OFF)
	set(USE_DX12   OFF)

	if (APPLE)
		set(USE_METAL ON)
	elseif (WIN32)
		# set(USE_DX12 ON)
		# target_compile_definitions(webgpu INTERFACE BACKEND_DX12)
	# else()
	# 	set(USE_VULKAN ON)
	# 	target_compile_definitions(webgpu INTERFACE BACKEND_VULKAN)
	endif()

	set(USE_VULKAN ON)
	target_compile_definitions(webgpu INTERFACE BACKEND_VULKAN)

	set(DAWN_ENABLE_METAL ${USE_METAL})
	set(DAWN_ENABLE_D3D12 ${USE_DX12})
	set(DAWN_ENABLE_VULKAN ${USE_VULKAN})

	set(DAWN_ENABLE_D3D11 OFF)
	set(DAWN_ENABLE_NULL OFF)
	set(DAWN_ENABLE_DESKTOP_GL OFF)
	set(DAWN_ENABLE_OPENGLES OFF)

	# Used for reflection
	set(TINT_BUILD_TINT ON)

	# Disable unneeded parts
	set(DAWN_BUILD_SAMPLES OFF)
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
	set(TINT_BUILD_CMD_TOOLS OFF)

	add_subdirectory(${dawn_SOURCE_DIR} ${dawn_BINARY_DIR})
endif ()

set(AllDawnTargets
	core_tables
	dawn_common
	dawn_glfw
	dawn_headers
	dawn_native
	dawn_platform
	dawn_proc
	dawn_utils
	dawn_wire
	dawncpp
	dawncpp_headers
	emscripten_bits_gen
	enum_string_mapping
	extinst_tables
	webgpu_dawn
	webgpu_headers_gen
	tint_api
	tint_utils_io
	tint_val
	tint-format
	tint-lint
)

set(AllGlfwTargets
	glfw
	update_mappings
	uninstall
)

function(filter_all_targets var)
    set(targets)
    get_all_targets_recursive(targets ${CMAKE_CURRENT_SOURCE_DIR})
    set(${var} ${targets} PARENT_SCOPE)
endfunction()

macro(get_all_targets_recursive targets dir)
    get_property(subdirectories DIRECTORY ${dir} PROPERTY SUBDIRECTORIES)
    foreach(subdir ${subdirectories})
        get_all_targets_recursive(${targets} ${subdir})
    endforeach()

    get_property(current_targets DIRECTORY ${dir} PROPERTY BUILDSYSTEM_TARGETS)
	set_property(TARGET ${current_targets} PROPERTY FOLDER "External/")
endmacro()

filter_all_targets(all_targets)

foreach (Target ${AllDawnTargets})
	if (TARGET ${Target})
		message(STATUS ${Target})
		set_property(TARGET ${Target} PROPERTY FOLDER "External/Dawn")
	endif()
endforeach()

foreach (Target ${AllGlfwTargets})
	if (TARGET ${Target})
		set_property(TARGET ${Target} PROPERTY FOLDER "External/GLFW3")
	endif()
endforeach()

# This is likely needed for other targets as well
# TODO: Notify this upstream (is this still needed?)
target_include_directories(dawn_utils PUBLIC "${CMAKE_BINARY_DIR}/_deps/dawn-src/src")
