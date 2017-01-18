```
###
#
#  Название: etitle.tcl
#  Версия: 1.3
#  Автор: tvrsh 
#  Оффсайт: http://egghelp.ru/
#
###
#
# Описание: Скрипт "простого" показа тайтлов вебстраничек.
#
###
#
# Установка: 
#         1. Скопируйте скрипт etitle.tcl в папку scripts вашего бота.
#         2. В файле eggdrop.conf впишите строку source scripts/etitle.tcl 
#         3. Сделайте .rehash боту.
#
###
#
# Версион хистори:
#
#              1.0(03.04.2010) Первая паблик версия.
#              1.1(26.05.2010) + Уточнения времени запроса (by Vertigo).
#                              + Удаление нежелательных символов из урл("({[) (by Vertigo).
#              1.2(01.11.2010) + TinyURL сокращение.
#                  02.12.2010  + Работа с Suzi патчем и небольшая доработка сокращения урлов.
#              1.3(18.01.2017) + Добавлена функция чёрного списка ссылок и работа с https ссылками, в том числе требующими SNI
###   
```
Обратите внимание, что поддержка SNI в данной реализации работает только при использовании tcl-tls версии 1.7.11 и выше.
Если ваша версия ниже, замените  в коде блок
```
http::register https 443 [list ::tls::socket -autoservername true]
```
на этот блок
```
    ::http::register https 443 tls:socket
 
    proc tls:socket args {
        set opts [lrange $args 0 end-2]
        set host [lindex $args end-1]
        set port [lindex $args end]
        ::tls::socket -ssl3 false -ssl2 false -tls1 true -servername $host {*}$opts $host $port
    }
```
