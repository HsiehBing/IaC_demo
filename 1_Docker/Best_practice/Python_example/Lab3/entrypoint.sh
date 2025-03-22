#!/bin/bash
set -e

COMMAND="$1"
shift

if [ "$COMMAND" = "run" ]; then
    echo "Starting Flask app..."
    # 使用 exec 讓 python3 app.py 變成 PID 1，以便接收信號 (ex: SIGTERM)
    # "$@" 表示剩餘的所有命令列參數
    exec python3 app.py "$@"
elif [ "$COMMAND" = "test" ]; then
    echo "Running unittests and generating XML report..."
    # 建立報告輸出目錄
    REPORT_DIR="/reports"
    mkdir -p ${REPORT_DIR}
    # 使用 xmlrunner 產生 XML 格式的測試報告，報告會輸出到 /reports 目錄中
    python3 -m xmlrunner discover -v -o ${REPORT_DIR}
else
    echo "Usage: $0 {run|test}"
    exit 1
fi
