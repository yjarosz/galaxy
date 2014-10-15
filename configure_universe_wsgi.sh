#!/bin/sh
UNIVERSE_FILE=$1

sed -i 's|#database_connection.*|database_connection = postgresql://galaxy:galaxy@127.0.0.1:5432/galaxy|g' "$UNIVERSE_FILE"
sed -i 's|#database_engine_option_pool_size.*|database_engine_option_pool_size = 5|g' "$UNIVERSE_FILE"
sed -i 's|#database_engine_option_max_overflow.*|database_engine_option_max_overflow = 10|g' "$UNIVERSE_FILE"
sed -i 's|#database_engine_option_server_side_cursors.*|database_engine_option_server_side_cursors = True|g' "$UNIVERSE_FILE"
sed -i 's|#database_engine_option_strategy.*|database_engine_option_strategy = threadlocal|g' "$UNIVERSE_FILE"
sed -i 's|#port = 8080|port = 8080|g' "$UNIVERSE_FILE"
sed -i 's|#host = 127.0.0.1|host = 0.0.0.0|g' "$UNIVERSE_FILE"
sed -i 's|#threadpool_workers = 10|threadpool_workers = 10|g' "$UNIVERSE_FILE"
sed -i 's|threadpool_kill_thread_limit.*|threadpool_kill_thread_limit = 10800\n[server:main2]\nuse = egg:Paste#http\nport = 8081\nhost = 0.0.0.0\nuse_threadpool = true\nthreadpool_workers = 7|g' "$UNIVERSE_FILE"
sed -i 's|#user_activation_on = False|user_activation_on = False|g' "$UNIVERSE_FILE"
sed -i 's|#tool_config_file = config/tool_conf.xml,shed_tool_conf.xml|tool_config_file = config/tool_conf.xml,config/tool_conf.xml.main|g' "$UNIVERSE_FILE"
sed -i 's|#brand = None|brand = RRR|g' "$UNIVERSE_FILE"
sed -i 's|#library_import_dir = None|library_import_dir = /home/galaxy/galaxy-dist/data|g' "$UNIVERSE_FILE"
sed -i 's|#admin_users = None|admin_users = admin@admin.com|g' "$UNIVERSE_FILE"
sed -i 's|#require_login = False|require_login = False|g' "$UNIVERSE_FILE"
