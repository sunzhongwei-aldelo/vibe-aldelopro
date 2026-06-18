#!/bin/bash

# ====================================================================
# XcodeGen 与 Git Worktree 一键自动化配置脚本
# ====================================================================

# 确保在出错时立即停止执行
set -e

echo "=================================================="
echo "🚀 开始配置 XcodeGen + Git Worktree 自动化开发环境..."
echo "=================================================="

# --------------------------------------------------------------------
# 1. 检测并安装 XcodeGen
# --------------------------------------------------------------------
if command -v xcodegen &> /dev/null; then
    echo "✅ 检测到系统已安装 XcodeGen: $(xcodegen --version)"
else
    echo "⚠️ 未检测到 XcodeGen，准备通过 Homebrew 进行安装..."
    
    if ! command -v brew &> /dev/null; then
        echo "❌ 错误: 未检测到 Homebrew。请先安装 Homebrew (https://brew.sh) 后再运行此脚本。"
        exit 1
    fi
    
    echo "⏳ 正在运行 'brew install xcodegen'，请稍候..."
    brew install xcodegen
    echo "✅ XcodeGen 安装成功！"
fi

# --------------------------------------------------------------------
# 2. 互动获取开发者名称并锁定前缀（必填项拦截）
# --------------------------------------------------------------------
echo "--------------------------------------------------"
echo "👤 正在初始化团队环境配置..."

while true; do
    read -p "请输入您的名字拼音 (必填项，例如: sunzhongwei): " DEV_NAME
    DEV_NAME=$(echo "$DEV_NAME" | xargs) # 自动去除两端空格
    
    if [ -z "$DEV_NAME" ]; then
        echo "❌ 错误：名称为必填项，不能为空，请重新输入！"
    else
        break
    fi
done

echo "✅ 已锁定开发者前缀: [ai-$DEV_NAME]"

# --------------------------------------------------------------------
# 3. 动态识别并一键建立本地独立 Worktree 沙盒
# --------------------------------------------------------------------
echo "--------------------------------------------------"
echo "📂 正在配置 Git Worktree 多工作区..."

# 动态获取主仓库的物理根目录信息
CURRENT_MAIN_DIR="$PWD"
PARENT_DIR=$(dirname "$PWD")
AI_WORKTREE_PATH="$PARENT_DIR/AldeloPro_AI"

# 检查是否已经建立了 Worktree
if git worktree list | grep -q "AldeloPro_AI"; then
    echo "ℹ️ 检测到本地已存在 AldeloPro_AI 工作树，跳过创建步骤。"
else
    echo "⏳ 正在平级目录创建专属 AI 物理隔离沙盒 (AldeloPro_AI)..."
    
    # 刷新一下远程分支数据
    git fetch origin --prune -q
    
    # 优先检测远程有没有现成的 ai-$DEV_NAME 分支
    LATEST_REMOTE_BRANCH=$(git for-each-ref --format='%(refname:short)' --sort=-committerdate refs/remotes/origin/ai-$DEV_NAME | head -n 1 || true)
    
    if [ -n "$LATEST_REMOTE_BRANCH" ]; then
        echo "🤖 发现远程已有您的活跃 AI 分支 $LATEST_REMOTE_BRANCH，直接挂载！"
        git worktree add "$AI_WORKTREE_PATH" "$LATEST_REMOTE_BRANCH"
    else
        echo "☕️ 远程暂无活跃的 [ai-$DEV_NAME/*] 分支，正在基于 main 初始化专属沙盒环境..."
        git worktree add "$AI_WORKTREE_PATH" -b "ai-$DEV_NAME-sandbox" main
    fi
    echo "✅ Worktree 沙盒区物理路径已就绪: $AI_WORKTREE_PATH"

    # 🟢 核心追加：切入沙盒内部，首次运行 xcodegen 初始化工程
    echo "⏳ 正在初始化沙盒内部 Xcode 工程骨架..."
    cd "$AI_WORKTREE_PATH"
    if [ -f "project.yml" ]; then
        # 确保注入 Homebrew 的标准路径，防止找不到命令
        export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
        xcodegen generate
        echo "✅ 沙盒工程初始化成功！"
    else
        echo "⚠️ 沙盒内未检测到 project.yml，跳过工程生成。"
    fi
    
    # 搞完之后，优雅、安全地退回大本营目录，继续后面的配置
    cd "$CURRENT_MAIN_DIR"
fi

# --------------------------------------------------------------------
# 4. 动态写入纯净、无卡顿风险的 autopull.sh 内容
# --------------------------------------------------------------------
echo "--------------------------------------------------"
echo "⚙️ 正在生成专属于 AI 沙盒的冷启动同步脚本 (autopull.sh)..."

cat << EOF > "autopull.sh"
#!/bin/sh
#
# ==============================================================================
# Xcode auto pull and generate project file via xcodegen (Worktree Edition)
# ==============================================================================

# 1. 物理切入给 AI 准备的专属独立工作区文件夹，绝对不会误伤人类本地代码
cd "$AI_WORKTREE_PATH"
export PATH="/opt/homebrew/bin:/usr/local/bin:\$PATH"

# 2. 刷新远程仓库索引
echo "🔄 正在同步远程服务器分支信息..."
git fetch origin --prune

# 3. 【精准追踪】动态获取远程服务器上，最新提交的、且属于你自己的 AI 分支
REMOTE_LATEST=\$(git for-each-ref --format='%(refname:short)' --sort=-committerdate refs/remotes/origin/ai-$DEV_NAME | head -n 1 | sed 's/origin\///')

# 如果远程当前没有你这个 AI 的活跃任务分支，安全退出
if [ -z "\$REMOTE_LATEST" ]; then
    echo "☕️ 远程没有检测到活跃的 [ai-$DEV_NAME/*] 分支，沙盒环境原地静默。"
    exit 0
fi

echo "🤖 [AI 追踪] 发现远程有最新推进的分支: \$REMOTE_LATEST"

# 4. 在独立沙盒内无缝切换、追踪并彻底重置强刷
echo "🚀 正在将沙盒代码 100% 强刷至远程 AI 分支最新状态..."
git checkout -B \$REMOTE_LATEST origin/\$REMOTE_LATEST
git reset --hard origin/\$REMOTE_LATEST

# 5. 生成该沙盒独立的 Xcode 工程
if [ -f "project.yml" ]; then
    echo "🛠 正在通过 XcodeGen 重新构建沙盒工程..."
    xcodegen generate
fi

echo "✅ [同步完成] 成功刷新 \$REMOTE_LATEST 代码，即将开始 Build。"
EOF

# 赋予自动生成的 autopull.sh 文件执行权限
chmod +x autopull.sh
echo "✅ 成功在工程根目录创建并授权：'autopull.sh'。"

# --------------------------------------------------------------------
# 5. 最终合闸：首次执行生成主仓库工程
# --------------------------------------------------------------------
echo "=================================================="
echo "🎉 恭喜！人类基地与 AI 沙盒全自动双轨架构配置成功！"
echo "👉 提示：你当前所在目录可以更名为 'AldeloPro_Main'，专门负责你写主线。"
echo "👉 隔壁的 'AldeloPro_AI' 文件夹配有专职的 autopull.sh，交给 AI 脚本去刷代码。"
echo "=================================================="

if [ -f "project.yml" ]; then
    echo "🔄 配置已就绪，正在首次自动生成主工程文件..."
    xcodegen generate
else
    echo "ℹ️ 未检测到 project.yml，跳过工程生成。"
fi