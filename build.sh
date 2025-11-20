#!/usr/bin/env bash
set -e

show_help() {
  cat << EOF
Usage: ./build.sh [COMMAND]

Commands:
  help        Show this help message
  clean       Remove the build directory (forces full reconfigure)
  config      Force rerun CMake configure even if build/ exists
  build       Build incrementally (default)
  rebuild     clean + config + build
EOF
}

# ============= Parse Commands ============= #

case "$1" in
  help)
    show_help
    exit 0
    ;;
  clean)
    echo "[CLEAN] Removing build directory..."
    rm -rf build
    exit 0
    ;;
  config)
    echo "[CONFIG] Forcing CMake configure..."
    rm -rf build
    ;;
  rebuild)
    echo "[REBUILD] Clean + config + build"
    rm -rf build
    ;;
  build|"")
    # no-op, default incremental build
    ;;
  *)
    echo "Unknown command: $1"
    echo "Run ./build.sh help for usage."
    exit 1
    ;;
esac

# ============= CMake Configure ============= #

if [[ ! -d build ]]; then
  echo "[INIT] Configuring build directory..."
  mkdir -p build
  cd build

  cmake .. -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CUDA_ARCHITECTURES="70;75;80;86;89;90;100" \
    -DCUTLASS_NVCC_ARCHS="70;75;80;86;89;90;100" \
    -DCUTLASS_NVCC_FLAGS="" \
    -DCUTLASS_NVCC_VERBOSE=ON \
    -DCUTLASS_ENABLE_CUDA_API=ON \
    -DCUTLASS_ENABLE_CUBLAS=ON \
    -DCUTLASS_ENABLE_CUDNN=OFF \
    -DCUTLASS_ENABLE_FP8=ON \
    -DCUTLASS_ENABLE_INT4=ON \
    -DCUTLASS_ENABLE_INT8=ON \
    -DCUTLASS_ENABLE_HALF=ON \
    -DCUTLASS_ENABLE_FP16=ON \
    -DCUTLASS_ENABLE_BF16=ON \
    -DCUTLASS_ENABLE_FP32=ON \
    -DCUTLASS_ENABLE_FP64=ON \
    -DCUTLASS_ENABLE_TENSOR_CORE_MMA=ON \
    -DCUTLASS_ENABLE_DEVICE_CODE=ON \
    -DCUTLASS_ENABLE_EXAMPLES=ON \
    -DCUTLASS_ENABLE_TESTS=ON \
    -DCUTLASS_ENABLE_GTEST=ON \
    -DCUTLASS_ENABLE_GMOCK=OFF \
    -DCUTLASS_TEST_UNIT=ON \
    -DCUTLASS_TEST_INTEGRATION=ON \
    -DCUTLASS_TEST_DISABLE_SM90=OFF \
    -DCUTLASS_TEST_NUMERIC_SM90=ON \
    -DCUTLASS_ENABLE_PROFILER=ON \
    -DCUTLASS_PROFILER_ENABLE_NVTX=ON \
    -DCUTLASS_ENABLE_NVTX=ON \
    -DCUTLASS_ENABLE_BACKWARD=ON \
    -DCUTLASS_ENABLE_DEBUG_TRACE=ON \
    -DCUTLASS_DEBUG_TRACE=ON \
    -DCUTLASS_DEBUG_LOG=ON \
    -DCUTLASS_ENABLE_LIBRARY=ON \
	  -DCUTLASS_LIBRARY_ENABLE_REFERENCES=ON \
    -DCUTLASS_LIBRARY_KERNELS=ALL \
    -DCUTLASS_LIBRARY_ENABLE_CUBLAS=ON \
    -DCUTLASS_LIBRARY_ENABLE_CUBLASLT=ON \
    -DCUTLASS_LIBRARY_ENABLE_NVRTC=ON \
    -DCUTLASS_LIBRARY_EMBED_DEVICE_CODE=ON \
    -DCUTLASS_LIBRARY_EMBED_MANIFEST=ON \
    -DCUTLASS_NVRTC_ENABLED=ON \
    -DCUTLASS_ALIGNMENT_MAX=16

  cd ..
fi

# ============= Build ============= #

echo "[BUILD] Incremental build running..."
cd build
make -j32
cd ..
