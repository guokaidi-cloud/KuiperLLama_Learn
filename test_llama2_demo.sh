#分词器：https://huggingface.co/yahma/llama-7b-hf/blob/main/tokenizer.model
#权重：https://huggingface.co/karpathy/tinyllamas/blob/main/stories110M.bin

# 安装到models目录下
mkdir -p models

# 尝试启用 AutoDL 学术加速（如果可用）
if [ -f /etc/network_turbo ]; then
    echo "检测到 AutoDL 环境，尝试启用学术加速..."
    source /etc/network_turbo 2>/dev/null && echo "✓ 学术加速已启用" || echo "⚠ 学术加速启用失败，继续使用其他方案"
fi

# 定义下载函数，支持多个镜像站点
download_file() {
    local url=$1
    local output=$2
    local filename=$(basename $output)
    local path="${url#https://huggingface.co}"
    
    # 方案1: 尝试使用 AutoDL 学术加速（如果已启用）
    if [ -n "$http_proxy" ] || [ -n "$https_proxy" ]; then
        echo "尝试使用代理下载 $filename..."
        if wget -O "$output" "$url" --timeout=60 --tries=3 2>/dev/null; then
            echo "✓ 使用代理下载成功"
            return 0
        fi
        if curl -L -o "$output" "$url" --connect-timeout 60 --max-time 600 2>/dev/null; then
            echo "✓ 使用 curl 和代理下载成功"
            return 0
        fi
    fi
    
    # 方案2: 尝试使用 hf-mirror.com 镜像站点
    echo "尝试使用 hf-mirror.com 镜像下载 $filename..."
    if wget -O "$output" "https://hf-mirror.com${path}" --timeout=60 --tries=3 2>/dev/null; then
        echo "✓ 使用 hf-mirror.com 镜像下载成功"
        return 0
    fi
    if curl -L -o "$output" "https://hf-mirror.com${path}" --connect-timeout 60 --max-time 600 2>/dev/null; then
        echo "✓ 使用 curl 和 hf-mirror.com 镜像下载成功"
        return 0
    fi
    
    # 方案3: 尝试使用原始 Hugging Face 链接
    echo "尝试使用原始链接下载 $filename..."
    if wget -O "$output" "$url" --timeout=60 --tries=3 2>/dev/null; then
        echo "✓ 使用原始链接下载成功"
        return 0
    fi
    if curl -L -o "$output" "$url" --connect-timeout 60 --max-time 600 2>/dev/null; then
        echo "✓ 使用 curl 和原始链接下载成功"
        return 0
    fi
    
    # 方案4: 尝试使用 ghproxy.com 代理（GitHub 代理，有时也支持 HF）
    echo "尝试使用 ghproxy.com 代理下载 $filename..."
    if wget -O "$output" "https://ghproxy.com/${url}" --timeout=60 --tries=3 2>/dev/null; then
        echo "✓ 使用 ghproxy.com 代理下载成功"
        return 0
    fi
    
    return 1
}

# 下载分词器（使用 resolve 而不是 blob 来获取直接下载链接）
if [ ! -f models/tokenizer.model ]; then
    echo "正在下载分词器..."
    if ! download_file "https://huggingface.co/yahma/llama-7b-hf/resolve/main/tokenizer.model" "models/tokenizer.model"; then
        echo "✗ 分词器下载失败，请尝试以下方法："
        echo "   1. 启用 AutoDL 学术加速: source /etc/network_turbo"
        echo "   2. 手动下载命令："
        echo "      wget -O models/tokenizer.model https://hf-mirror.com/yahma/llama-7b-hf/resolve/main/tokenizer.model"
        echo "   3. 或使用 curl:"
        echo "      curl -L -o models/tokenizer.model https://hf-mirror.com/yahma/llama-7b-hf/resolve/main/tokenizer.model"
    fi
else
    echo "✓ 分词器文件已存在，跳过下载"
fi

# 下载权重文件
if [ ! -f models/stories110M.bin ]; then
    echo "正在下载权重文件..."
    if ! download_file "https://huggingface.co/karpathy/tinyllamas/resolve/main/stories110M.bin" "models/stories110M.bin"; then
        echo "✗ 权重文件下载失败，请尝试以下方法："
        echo "   1. 启用 AutoDL 学术加速: source /etc/network_turbo"
        echo "   2. 手动下载命令："
        echo "      wget -O models/stories110M.bin https://hf-mirror.com/karpathy/tinyllamas/resolve/main/stories110M.bin"
        echo "   3. 或使用 curl:"
        echo "      curl -L -o models/stories110M.bin https://hf-mirror.com/karpathy/tinyllamas/resolve/main/stories110M.bin"
    fi
else
    echo "✓ 权重文件已存在，跳过下载"
fi

# 检查文件是否下载成功
if [ -f models/tokenizer.model ] && [ -f models/stories110M.bin ]; then
    echo "✓ 文件下载成功！"
    ls -lh models/
else
    echo "✗ 文件下载失败，请检查网络连接或手动下载"
fi

# 运行demo
./build/demo/llama_infer models/stories110M.bin models/tokenizer.model