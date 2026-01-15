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
		git pull --depth=1 https://github.com/upf-gti/dawn &&
		git reset --hard FETCH_HEAD
)

FetchContent_GetProperties(dawn)

set(DAWN_FETCH_DEPENDENCIES ON)

set(USE_METAL  OFF)
set(USE_VULKAN OFF)
set(USE_DX12   OFF)

if (APPLE)
	set(USE_METAL ON)
elseif (WIN32)
	set(USE_DX12 ON)
	# target_compile_definitions(webgpu INTERFACE BACKEND_DX12)
	set(TINT_BUILD_HLSL_WRITER ON)

	set(USE_VULKAN ON)
	# target_compile_definitions(webgpu INTERFACE BACKEND_VULKAN)
else()
	set(USE_VULKAN ON)
	# target_compile_definitions(webgpu INTERFACE BACKEND_VULKAN)
endif()

message(STATUS "Dawn use Metal ${USE_METAL}")
message(STATUS "Dawn use Vulkan ${USE_VULKAN}")
message(STATUS "Dawn use DX12 ${USE_DX12}")

# Build Dawn as static library
set(DAWN_BUILD_MONOLITHIC_LIBRARY STATIC)
set(BUILD_SHARED_LIBS OFF)

set(DAWN_ENABLE_METAL ${USE_METAL})
set(DAWN_ENABLE_D3D12 ${USE_DX12})
set(DAWN_ENABLE_VULKAN ${USE_VULKAN})

if (WGPU_USE_X11)
	set(DAWN_USE_WAYLAND OFF)
	set(DAWN_USE_X11 ON)
elseif (WGPU_USE_WAYLAND)
	set(DAWN_USE_X11 OFF)
	set(DAWN_USE_WAYLAND ON)
endif()

# Used for reflection
set(TINT_BUILD_TINT ON)

# Disable unneeded parts
set(DAWN_BUILD_SAMPLES OFF)
set(DAWN_ENABLE_SPIRV_VALIDATION OFF)
set(DAWN_USE_GLFW OFF)
set(DAWN_ENABLE_D3D11 OFF)
set(DAWN_ENABLE_NULL OFF)
set(DAWN_ENABLE_DESKTOP_GL OFF)
set(DAWN_ENABLE_OPENGLES OFF)

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
set(TINT_BUILD_IR_BINARY OFF)

FetchContent_MakeAvailable(dawn)

set(AllDawnTargets
	core_tables
	dawn_common
	dawn_glfw
	dawn_headers
	dawn_native
	dawn_platform
	dawn_proc
	dawn_wire
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
