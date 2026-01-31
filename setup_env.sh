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
# 编译：-j8 表示用 8 核，核数多可调大（如 -j16）
${SUDO_CMD} make -j8
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
${SUDO_CMD} make -j8
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
${SUDO_CMD} make -j8
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
${SUDO_CMD} make -j8
# 安装
${SUDO_CMD} make install