if (MSVC)
    # Setting this to true brakes Visual Studio builds.
    set(CUDA_ATTACH_VS_BUILD_RULE_TO_CUDA_FILE OFF CACHE BOOL "CUDA_ATTACH_VS_BUILD_RULE_TO_CUDA_FILE")
endif ()

if (CMAKE_VERSION VERSION_GREATER_EQUAL 3.11)
    include(CheckLanguage)
    check_language(CUDA)
    if (CMAKE_CUDA_COMPILER)
        enable_language(CUDA)

        if (CMAKE_VERSION VERSION_GREATER_EQUAL 3.17)
            find_package(CUDAToolkit QUIET)
            set(CUDA_TOOLKIT_INCLUDE ${CUDAToolkit_INCLUDE_DIRS})
        else ()
            set(CUDA_FIND_QUIETLY TRUE)
            find_package(CUDA 9.0)
        endif ()

        set(CUDA_FOUND TRUE)
        set(CUDA_VERSION_STRING ${CMAKE_CUDA_COMPILER_VERSION})
    else ()
        message(STATUS "No CUDA compiler found")
    endif ()
else ()
    set(CUDA_FIND_QUIETLY TRUE)
    find_package(CUDA 9.0)
endif ()

if (CUDA_FOUND)
    message(STATUS "Found CUDA Toolkit v${CUDA_VERSION_STRING}")

    # 允许手动指定 CUDA 架构，如果没有指定则自动检测
    if (NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
        include(FindCUDA/select_compute_arch)
        CUDA_DETECT_INSTALLED_GPUS(INSTALLED_GPU_CCS_1)
        string(STRIP "${INSTALLED_GPU_CCS_1}" INSTALLED_GPU_CCS_2)
        string(REPLACE " " ";" INSTALLED_GPU_CCS_3 "${INSTALLED_GPU_CCS_2}")
        string(REPLACE "." "" CUDA_ARCH_LIST "${INSTALLED_GPU_CCS_3}")
        
        # 过滤掉不支持的架构（根据 CUDA 版本）
        # CUDA 12.8 支持到 compute_120 (RTX 5090)
        # 移除 compute_86 等可能不支持的架构
        set(SUPPORTED_ARCHS "")
        foreach(ARCH ${CUDA_ARCH_LIST})
            # 只保留支持的架构：60, 61, 70, 75, 80, 86, 89, 90, 100, 120
            # 如果检测到 86 但 CUDA 版本不支持，可以手动过滤
            if (ARCH MATCHES "^[0-9]+$")
                # 检查架构是否在合理范围内（60-120）
                if (ARCH GREATER_EQUAL 60 AND ARCH LESS_EQUAL 120)
                    list(APPEND SUPPORTED_ARCHS ${ARCH})
                endif()
            endif()
        endforeach()
        
        # 如果没有检测到支持的架构，使用默认值（根据 GPU 计算能力 12.0）
        if (SUPPORTED_ARCHS STREQUAL "")
            set(SUPPORTED_ARCHS "120")
            message(WARNING "No supported GPU architecture detected, using default: 120")
        endif()
        
        SET(CMAKE_CUDA_ARCHITECTURES ${SUPPORTED_ARCHS})
    endif()
    MESSAGE(STATUS "CMAKE_CUDA_ARCHITECTURES: ${CMAKE_CUDA_ARCHITECTURES}")

    if (DEFINED CMAKE_CUDA_COMPILER_LIBRARY_ROOT_FROM_NVVMIR_LIBRARY_DIR)
        set(CMAKE_CUDA_COMPILER_LIBRARY_ROOT "${CMAKE_CUDA_COMPILER_LIBRARY_ROOT_FROM_NVVMIR_LIBRARY_DIR}")
    elseif (EXISTS "${CMAKE_CUDA_COMPILER_TOOLKIT_ROOT}/nvvm/libdevice")
        set(CMAKE_CUDA_COMPILER_LIBRARY_ROOT "${CMAKE_CUDA_COMPILER_TOOLKIT_ROOT}")
    elseif (CMAKE_SYSROOT_LINK AND EXISTS "${CMAKE_SYSROOT_LINK}/usr/lib/cuda/nvvm/libdevice")
        set(CMAKE_CUDA_COMPILER_LIBRARY_ROOT "${CMAKE_SYSROOT_LINK}/usr/lib/cuda")
    elseif (EXISTS "${CMAKE_SYSROOT}/usr/lib/cuda/nvvm/libdevice")
        set(CMAKE_CUDA_COMPILER_LIBRARY_ROOT "${CMAKE_SYSROOT}/usr/lib/cuda")
    else ()
        message(FATAL_ERROR "Couldn't find CUDA library root.")
    endif ()
    unset(CMAKE_CUDA_COMPILER_LIBRARY_ROOT_FROM_NVVMIR_LIBRARY_DIR)
else ()
    message(STATUS "CUDA was not found.")
endif ()