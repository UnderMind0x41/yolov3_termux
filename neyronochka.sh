<< '#'
    # https://github.com/UnderMind0x41/yolov3_termux
	# Для Вас, дорогие подписчики, всё расписано. Это команды для ручной установки скрипта.
	# Пригодится, если через год-два опять какие-то зависимости сломаются.

	pkg update
	pkg install wget gnupg make curl python-tkinter clang nano git
	wget -O - https://cctools.info/public.key | apt-key add -
	echo "deb https://cctools.info termux cctools" > $PREFIX/etc/apt/sources.list.d/cctools.list
	pkg update
	pkg install gcc-cctools ndk-sysroot-cctools-api-26-aarch64
	export PATH=$PREFIX/../cctools-toolchain/bin:$PATH
	gcc -v

	git clone https://github.com/pjreddie/darknet
	cd darknet
	wget https://pjreddie.com/media/files/yolov3.weights

	make

	pip3 install opencv-python  # Если планируем использовать opencv, в дальнейших роликах об этом расскажу
#

cd ~
STORAGE="/sdcard"  # Подправьте эту переменную, если у вас другой путь к внутренней памяти смартфона или карте памяти

echo -e "Скрипт от UnderMind устанавливающий нейроночку для определения объектов на фото.\n"
echo -e "Вопросы и предложения по работе скрипта можете оставлять в комментариях: https://youtube.com/TheUnderMind \n"
# sleep 2
echo -e "Поскольку это тот же самый Linux, от версии к версии тут может что-то переставать работать."
echo -e "В комментариях в этом скрипте указан список команд для ручной установки всех зависимостей, на случай, если вы столкнулись с какой-то ошибкой.\n"
# sleep 2
if ! [ -d /data/data/com.termux/ ]
then
		echo -e "*** Ошибка: Скрипт может выполняться только в Termux. У Вас он, похоже, даже не установлен.\n\nЗавершение работы ... "
		exit 1
fi

echo -e "*** Важно:\n - Убедитесь, что разрешили Термуксу доступ к внутренней памяти смартфона!\n - Убедитесь, что смартфон подключен к интернету\n\n"
# input = "Нажмите enter для продолжения ... "

echo -en "Проверяю доступность интернета ... "
check_inet=$(ping -c 3 8.8.8.8 | tail -2 | head -1 | awk '{print $4}')
if [ $check_inet -eq 0 ]; then
	echo -e "\n\n*** Ошибка выполнения скрипта: Похоже вы не подключены к интернету, или что-то блокирует соединение.\n\nЗавершение работы ..."
	exit 1
else echo "Сеть доступна!"
fi

echo -en "Возможность записи во внутреннюю память смартфона (в /sdcard) ... "
if [ -d $STORAGE ] && echo "ok" > $STORAGE/writing_test
then
	rm $STORAGE/writing_test
	echo -e "Ok! Память доступна для записи.\n"
else
	echo -e "*** Ошибка: Внутренняя память не доступна.\nВозможно Вы не разрешили доступ термуксу ко внутренней памяти смартфона?\n\nКак это исправить на примере Xiaomi:\n - Настройки\n > Приложения\n > Разрешения приложений\n > Права доступа (Разрешения)\n > Хранение данных (Доступ к хранилищу, внутренний накопитель)\n > Разрешить"
	echo -e "Если Вы точно выдали разрешение, но скрипт по прежнему не работает, попробуйте исправить переменную STORAGE в этом файле скрипта.\nВведите туда путь до своей внутренней памяти, иногда это /storage/emulated/ или /storage/sdcard/"
	exit 1
fi

echo -e "Начинаю обновление списка пакетов ... "
if ! ( apt update -y )
	then 
		echo "Произошла ошибка при обновлении списка пакетов."
		echo -е "Вы точно подключены к интернету?\n"
		echo "Завершение работы скрипта ..."
	else
		echo -e "Ok!\n" 
fi

echo "Обновляю пакеты ... "
apt upgrade -y && echo -e "Ok!\n"

echo -en "Выполняю установку пакетов: wget gnupg make curl python-tkinter clang nano git\n"
if ! ( pkg install wget gnupg make curl python-tkinter clang nano git -y )
	then
		echo -e "\n *** При установке пакетов произошла ошибка!\nСкорее всего это связано с тем, что обновления опять сломали какие-то зависимости. Попробуйте вручную установку этих пакетов:\n >>> wget gnupg make curl python-tkinter clang nano git\n\nТак же не ленитесь пользоваться гуглом, при помощи него решаются 99% всех проблем :) \n"
		echo -e "\nЗавершение работы скрипта ..."
		exit 1
	else
		echo -e "\nВсе пакеты успешно установлены!\n\n"
fi

echo -e "Проверяю, есть ли у вас gcc ... \n"
gcc -v && echo -e "gcc найден, но всё-же попробуем установить более подходящую версию.\n"

echo -e "Импорт ключа ... "
( wget -O - https://cctools.info/public.key | apt-key add - ) && echo -e "Импорт ключа выполнен успешно!\n\n"

echo -e "Повторно обновляю список доступных пакетов через pkg update -y \n"
pkg update -y && echo -e "Ok\n\n"

echo -en "Выполняю установку пакетов для gcc: gcc-cctools ndk-sysroot-cctools-api-26-aarch64\n"
if ! ( pkg install gcc-cctools ndk-sysroot-cctools-api-26-aarch64 -y )
	then
		echo -e "\n *** При установке пакетов gcc-cctools ndk-sysroot-cctools-api-26-aarch64 произошла ошибка!\nЭто не критично, ведь сейчас в Termux по умолчанию устанавливается своя версия gcc, можно попробовать продолжить со встроенной версией.\n"
	else
		echo -e "\nВсе пакеты успешно установлены!\n\n"
		echo -e "Произвожу экспорт переменных среды ..."
		export PATH=$PREFIX/../cctools-toolchain/bin:$PATH
		gcc -v && echo -e "\nВау, версия gcc вроде бы даже обновлена!\n"
fi

if [ -d "darknet" ] 
then
	echo -e "Выглядит, будто вы уже ранее скачивали эту нейроночку.\n"
	echo -e "Переименовываю старую папку darknet... \n"
	mv darknet darknet_old_${RANDOM} 
fi
echo -e "\nПриступаем к скачиванию репозитория с нейроночкой ..."
sleep 2

if ! ( git clone https://github.com/pjreddie/darknet )
	then
		echo -e "\n *** При клонировании репозитория https://github.com/pjreddie/darknet произошла ошибка!\nВозможно репозиторий перемещен или удален.\nЗа подробностями можете зайти под ролик про нейронку на YouTube канале UnderMind, там наверняка уже будет решение этой проблемы."
		exit 1
	else
		echo -e "\nРепозиторий склонирован успешно!\n"
fi

echo -e "Переходим в папку с репозиторием и скачиваем туда веса ... Это займет много времени.\n"
cd darknet
if ( wget https://pjreddie.com/media/files/yolov3.weights )
	then 
		echo -e "Файл весов скачан, теперь можно приступить к компилляции этой нероночки.\n"
	else
		echo -e "Файл весов не был скачан! Возможно его удалили или у вас проблемы с сетью.\nБез файла весов нейроночка работать не будет!"
		echo -e "\nЗавершение работы скрипта ..."
		exit 1
fi

echo -e "Все предыдущие этапы вроде прошли без ошибок!\nПриступаем к самому главному этапу: Компилляция нейроночки из исходного кода ...\n\n На warning не обращайте внимания, это не критично"

sleep 3
make && echo -e "\n\n\n *** Нейроночка была собрана, ура! Пользуйтесь!\n\n\n" || echo -e "\n\n\n *** ОШИБКА: Какая-та проблема при сборке нейроночки ... \nВозможно Вам стоит проверить все этапы вручную. Вы точно установили все пакеты и их зависимости?\n\nЗавершение работы скрипта..."

echo "
if [ -f ~/storage/shared/detect.jpg ]
then
	rm predictions.jpg > /dev/null 2>&1; rm ~/storage/shared/result.jpg > /dev/null 2>&1; ./darknet detect cfg/yolov3.cfg yolov3.weights ~/storage/shared/detect.jpg && cp predictions.jpg ~/storage/shared/result.jpg
else
	echo -e \"***\\n*** ОШИБКА: Файл /sdcard/detect.jpg или ~/storage/shared/detect.jpg не существует!\\n***\"
	echo -e \"\\nЗапуск скрипта: ./detect.sh\\n\\nПеред запуском переименуйте фото, которое хотите проверить в detect.jpg и поместите его в sdcard\\nЕсли хотите использовать свои названия файлов, используйте другую утилиту: ./detect_custom.sh Файл_1 Файл_2\\n\"
	exit 1
fi
" > detect.sh
chmod +x detect.sh && echo -e "\nПрава на запуск detect.sh файла успешно выданы!\n"

sleep 1

echo "if [ ! -z \$1 ] && [ ! -z \$2 ]
then
	if [ -f ~/storage/shared/\$1 ]
	then
		rm predictions.jpg > /dev/null 2>&1; ./darknet detect cfg/yolov3.cfg yolov3.weights ~/storage/shared/\$1 && cp predictions.jpg ~/storage/shared/\$2
	else
		echo -e \"***\\n*** ОШИБКА: Файл /sdcard/\$1 или ~/storage/shared/\$1 не существует!\\n***\"
	fi
fi
echo -e \"\\nЗапуск скрипта: ./detect_custom.sh Файл_1 Файл_2\\n\\nГде Файл_1 - Название исходного файла на sdcard, а Файл_2 - Название выходного файла на sdcard\\n*** Внимание! Названия вводятся без указания пути!\\n\\nПример: ./detect_custom.sh myphoto.jpg detected.jpg\\n\\n\"
exit 1
" > detect_custom.sh
chmod +x detect_custom.sh && echo -e "\nПрава на запуск detect_custom.sh файла успешно выданы!\n"

sleep 1

echo "rm predictions.jpg > /dev/null 2>&1; rm ~/storage/shared/test.jpg > /dev/null 2>&1; ./darknet detect cfg/yolov3.cfg yolov3.weights data/dog.jpg && cp predictions.jpg ~/storage/shared/test.jpg" > test.sh
chmod +x test.sh && echo -e "\nПрава на запуск тестового файла успешно выданы!\n"

sleep 2

echo -e "\nЗапускаю файл для тестирования нейронной сети ..."
sleep 4
bash ./test.sh && echo -e "Тестовое определение прошло успешно!\n\nСмотрите выходной файл test.jpg в корневом каталоге внутренней памяти смартфона!\n\n"

echo "
Скрипты: 
./test.sh - Запускает тестовое определение объекта, выходной файл будет во внутренней памяти (/sdcard/)
./detect.sh - Запуск определения из файла detect.jpg находящегося во внутренней памяти (/sdcard/), результат сохраняется в файл result.jpg
./detect_custom.sh Файл_1 Файл_2 - Запуск детекта из файла_1 в файл_2. Указываются названия файлов на внутренней памяти смартфона без указания пути! Пример: ./detect_custom.sh myphoto.jpg outfile.jpg

"
