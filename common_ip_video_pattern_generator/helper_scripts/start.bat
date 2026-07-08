if not exist ".\images" mkdir ".\images"
py parse_images.py ..\tb_dump_data\non_existing.data 640 512 8 .\images\non_existing.png
py parse_images.py ..\tb_dump_data\all_black.data 640 512 8 .\images\all_black.png
py parse_images.py ..\tb_dump_data\all_intermediate.data 640 512 8 .\images\all_intermediate.png
py parse_images.py ..\tb_dump_data\all_white.data 640 512 8 .\images\all_white.png
py parse_images.py ..\tb_dump_data\checker_cols.data 640 512 8 .\images\checker_cols.png
py parse_images.py ..\tb_dump_data\gradient_horizontal.data 640 512 8 .\images\gradient_horizontal.png
py parse_images.py ..\tb_dump_data\checker_image.data 640 512 8 .\images\checker_image.png
py parse_images.py ..\tb_dump_data\checker_rows.data 640 512 8 .\images\checker_rows.png
py parse_images.py ..\tb_dump_data\gradient_vertical.data 640 512 8 .\images\gradient_vertical.png
py parse_images.py ..\tb_dump_data\gradient_xored.data640 512 8 .\images\gradient_xored.png