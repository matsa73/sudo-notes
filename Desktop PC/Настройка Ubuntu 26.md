# Настройка Ubuntu 26 Desktop

1. Видеоплеер и кодеки: `sudo apt install celluloid ubuntu-restricted-extras nvidia-vaapi-driver`

   - `celluloid` - видеоплеер
   - `ubuntu-restricted-extras` - метапакет, который тянет за собой набор кодеков, шрифтов и Flash Player, отсутствующих в системе.
   - `nvidia-vaapi-driver` - пакет для аппаратного декодирования в браузере на NVIDIA

2. Просмотр фото: `sudo apt install libheif-plugin-ffmpegdec` (или `libheif-plugins-all`)
Если после этого миниатюры HEIC не подтягиваются в Files: `rm -rf ~/.cache/thumbnails && nautilus -q`.

3. Архивы: `sudo apt install 7zip unrar-free`
4. [[Google Chrome]]
5. [[Подключение к VPS по SSH-ключу#Настройка для удобства]]
6. [[Shadowsocks + v2ray-plugin client]]

OK 9. VS Code
OK 10. Git
    - настройка ssh ключа (пуш не работает по парольной аутентификации)
