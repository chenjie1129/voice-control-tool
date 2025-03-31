#!/bin/bash
cd /Users/bytedance/Downloads/aiTools/extersion/tools/projects/assistant/demo/VoiceControlTool

echo "正在准备构建环境..."
mkdir -p Sources/VoiceControlTool
mv Sources/*.swift Sources/VoiceControlTool/ 2>/dev/null

echo "开始构建项目..."
if swift build; then
    echo "构建成功！正在启动应用..."
    open .build/debug/VoiceControlTool
else
    echo "构建失败，请检查错误信息"
    exit 1
fi