#分词器：https://huggingface.co/fushenshen/lession_model/resolve/main/tokenizer.json
#权重：https://huggingface.co/fushenshen/lession_model/resolve/main/llama32_1bnq.bin

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
if [ ! -f models/tokenizer.json ]; then
    echo "正在下载分词器..."
    if ! download_file "https://huggingface.co/fushenshen/lession_model/resolve/main/tokenizer.json" "models/tokenizer.json"; then
        echo "✗ 分词器下载失败，请尝试以下方法："
        echo "   1. 启用 AutoDL 学术加速: source /etc/network_turbo"
        echo "   2. 手动下载命令："
        echo "      wget -O models/tokenizer.json https://hf-mirror.com/fushenshen/lession_model/resolve/main/tokenizer.json"
        echo "   3. 或使用 curl:"
        echo "      curl -L -o models/tokenizer.json https://hf-mirror.com/fushenshen/lession_model/resolve/main/tokenizer.json"
    fi
else
    echo "✓ 分词器文件已存在，跳过下载"
fi

# 下载权重文件
if [ ! -f models/llama32_1bnq.bin ]; then
    echo "正在下载权重文件..."
    if ! download_file "https://huggingface.co/fushenshen/lession_model/resolve/main/llama32_1bnq.bin" "models/llama32_1bnq.bin"; then
        echo "✗ 权重文件下载失败，请尝试以下方法："
        echo "   1. 启用 AutoDL 学术加速: source /etc/network_turbo"
        echo "   2. 手动下载命令："
        echo "      wget -O models/llama32_1bnq.bin https://hf-mirror.com/fushenshen/lession_model/resolve/main/llama32_1bnq.bin"
        echo "   3. 或使用 curl:"
        echo "      curl -L -o models/llama32_1bnq.bin https://hf-mirror.com/fushenshen/lession_model/resolve/main/llama32_1bnq.bin"
    fi
else
    echo "✓ 权重文件已存在，跳过下载"
fi

# 检查文件是否下载成功
if [ -f models/tokenizer.json ] && [ -f models/llama32_1bnq.bin ]; then
    echo "✓ 文件下载成功！"
    ls -lh models/
else
    echo "✗ 文件下载失败，请检查网络连接或手动下载"
    exit 1
fi

# 运行demo
echo "正在运行 Llama3 推理..."
./build/demo/llama_infer models/llama32_1bnq.bin models/tokenizer.json
