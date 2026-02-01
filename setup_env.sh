# 判断是否为 root 用户：如果是 root 则不加 sudo，否则加 sudo
if [ "$EUID" -eq 0 ]; then
    SUDO_CMD=""
else
    SUDO_CMD="sudo"
fi

# 配置 git 以加速克隆（增加缓冲区和超时时间）
git config --global http.postBuffer 524288000
git config --global http.lowSpeedLimit 0
git config --global http.lowSpeedTime 999999

# 使用浅克隆加速（只克隆最新版本，减少下载量）
git clone --depth 1 https://gitee.com/mirrors/armadillo-code.git ~/armadillo

# 进入源码目录
cd ~/armadillo
# 创建 build 目录（分离编译文件与源码）
mkdir build && cd build || true
# 生成 Makefile（Release 模式，优化编译）
cmake -DCMAKE_BUILD_TYPE=Release ..
# 编译：-j32 表示用 8 核，核数多可调大（如 -j16）
${SUDO_CMD} make -j32
# 安装到系统目录（需 sudo 权限），如果已经是sudo则不需要
${SUDO_CMD} make install  


# 使用 GitHub 镜像或浅克隆加速
# 方案1: 使用 Gitee 镜像（推荐，速度最快）
git clone --depth 1 https://gitee.com/mirrors/googletest.git ~/googletest || \
# 方案2: 如果镜像失败，使用 GitHub 浅克隆
git clone --depth 1 https://github.com/google/googletest.git ~/googletest

cd ~/googletest
# 创建 build 目录
mkdir build && cd build || true
# 生成 Makefile（Release 模式）
cmake -DCMAKE_BUILD_TYPE=Release .. 
# 编译 
${SUDO_CMD} make -j32
# 安装（默认路径：头文件 /usr/local/include，库文件 /usr/local/lib）
${SUDO_CMD} make install


# 使用浅克隆加速
git clone --depth 1 https://gitee.com/mirrors/glog.git ~/glog || \
git clone --depth 1 https://github.com/google/glog.git ~/glog

# 进入源码目录
cd ~/glog
# 创建 build 目录
mkdir build && cd build || true
# 生成 Makefile：关闭 WITH_GFLAGS 和 WITH_GTEST（避免额外依赖）
cmake -DCMAKE_BUILD_TYPE=Release -DWITH_GFLAGS=OFF -DWITH_GTEST=OFF ..
# 编译
${SUDO_CMD} make -j32
# 安装
${SUDO_CMD} make install

# 使用浅克隆加速
git clone --depth 1 https://gitee.com/mirrors/sentencepiece.git ~/sentencepiece || \
git clone --depth 1 https://github.com/google/sentencepiece.git ~/sentencepiece

cd ~/sentencepiece
# 创建 build 目录
mkdir build && cd build || true
# 生成 Makefile（Release 模式）
cmake -DCMAKE_BUILD_TYPE=Release .. 
# 编译
${SUDO_CMD} make -j32
# 安装
${SUDO_CMD} make install

# 安装 abseil-cpp
# 使用浅克隆加速，优先使用 Gitee 镜像
git clone --depth 1 https://gitee.com/mirrors/abseil-cpp.git ~/abseil-cpp || \
git clone --depth 1 https://github.com/abseil/abseil-cpp.git ~/abseil-cpp

cd ~/abseil-cpp
# 创建 build 目录
mkdir build && cd build || true
# 生成 Makefile（Release 模式，启用 -fPIC 以支持链接到共享库）
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON ..
# 编译
${SUDO_CMD} make -j32
# 安装
${SUDO_CMD} make install

# 安装 re2
# 使用浅克隆加速，优先使用 Gitee 镜像
git clone --depth 1 https://gitee.com/mirrors/re2.git ~/re2 || \
git clone --depth 1 https://github.com/google/re2.git ~/re2

cd ~/re2
# 创建 build 目录
mkdir build && cd build || true
# 生成 Makefile（Release 模式，启用 -fPIC 以支持链接到共享库）
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_POSITION_INDEPENDENT_CODE=ON ..
# 编译
${SUDO_CMD} make -j32
# 安装
${SUDO_CMD} make install

# 安装 nlohmann/json（header-only 库）
# 使用浅克隆加速，优先使用 Gitee 镜像
git clone --depth 1 https://gitee.com/mirrors/json.git ~/json || \
git clone --depth 1 https://github.com/nlohmann/json.git ~/json

cd ~/json
# nlohmann/json 是 header-only 库，可以直接安装头文件
# 创建安装目录
mkdir -p build && cd build || true
# 生成 Makefile（Release 模式）
cmake -DCMAKE_BUILD_TYPE=Release ..
# 编译（虽然主要是头文件，但可能有一些测试或工具需要编译）
${SUDO_CMD} make -j32
# 安装
${SUDO_CMD} make install