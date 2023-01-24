program booktell;

type
    myrecord = record
        firstN, lastN: string;
        numberTell: int64;
    end;

    listed = ^ptr;
    ptr = record
        date: myrecord;
        next: listed;
    end;

var
    tfile: file of myrecord;
    zapis: myrecord;
    vibor: integer;
    list: listed;

procedure ListPut(var list: listed);
var
    first ,tmp: listed;
begin
    new(first);
    first^.date.firstN := zapis.firstN;
    first^.date.lastN := zapis.lastN;
    first^.date.numberTell := zapis.numberTell;
    first^.next := Nil;

    if list = Nil then
    begin
        list := first;
        exit;
    end;

    tmp := list;
    while tmp^.next <> Nil do
    begin
        tmp := tmp^.next;
    end;
    tmp^.next := first;
end;

procedure DelletMi (x: integer);
var 
    temp, current: listed;
    a: byte;
begin


    if list = Nil then
    begin
        // writeln('List is empaty!');
        exit;
    end;   

    temp := list;
    current := Nil;
    a := 0;
  
    while temp <> Nil do
    begin
        if a = x then
        begin
            if current = Nil then
            begin
                list := temp^.next;
            end else begin
                current^.next := temp^.next;
            end;
            Dispose(temp);
            exit;
        end;
        current := temp;
        temp := temp^.next;
        a := a + 1;
    end;
    writeln('В списку не достатньо елементів!')
end;


procedure AddListed();
begin

    if eof(tfile) = True then
    begin
        // writeln('File empty!');
        exit;
    end;

    while not eof(tfile) do
    begin
        read(tfile, zapis);
        // writeln(zapis.firstN, ' ', zapis.lastN, ' ', zapis.numberTell);
        ListPut(list);
    end;
end;


procedure AddContakt();
var 
    z: myrecord;
begin
    with z do
    begin
        write('Pleas write First Name: ');
        readln(firstN);
        write('Pleas write Last Name: ');
        readln(lastN);
        write('Pleas write number tell: +380');
        readln(numberTell);
    end;
    
    seek(tfile, filesize(tfile));
    write(tfile, z);
end;


procedure SortArrayLast();
var
    arr: Array[1..100] of string;
    z: myrecord;
    i, j: byte; 
    used_elements: integer;
    s: string;

begin


    if filesize(tfile) = 0 then
    begin
        writeln('Телефонна книга пуста!');
        exit;
    end;

    used_elements := 0;
    seek(tfile, 0);
    AddListed;

    while list <> Nil do
    begin
        writeln(list^.date.lastN);
        list := list^.next;
    end;

    while list <> Nil do
        begin
            arr[used_elements + 1] := list^.date.lastN; // LowerCase(z.lastN);
            inc(used_elements);
            list := list^.next;
        end;
    
    for i:= 1 to used_elements-1 do
        for j:= 1 to used_elements-i do
        begin
            if arr[j] > arr[j+1] then 
            begin
                s := arr[j];
                arr[j] := arr[j+1];
                arr[j+1] := s;
            end;
        end;
    


    
    // for i := 1 to used_elements do
    //     writeln(arr[i]);

    // //Чому тут просто не вивести масив? Не бачу сенсу вичитувати файлик знову
    // //Трохи криво
    for i := 1 to used_elements do
    begin
        while list <> Nil do
        begin
            if arr[i] = list^.date.lastN then
                writeln(list^.date.lastN, ' ', list^.date.firstN, ' ', '+380', list^.date.numberTell);
            // writeln(list^.date.firstN);
            list := list^.next;
        end;
    end; 
    
end;


procedure DellContakt();
var
    z: myrecord;
    search: int64;
    pos: integer;
    prapor: boolean;
begin
    write('Введіть номер: +380');
    readln(search);
    seek(tfile, 0);
    prapor := False;
    while not eof(tfile) do
    begin
        read(tfile, z);
        if search = z.numberTell then
        begin
            pos := filepos(tfile);
            prapor := True;
        end;
    end;
    if prapor = False then
    begin
        writeln('Номер не знайдено!');
        exit;
    end;

    seek(tfile, 0);
    AddListed();
    close(tfile);

    DelletMi(pos-1);

    rewrite(tfile);
    while list <> Nil do
    begin
        with z do
        begin
	    //Ми повинні кожен раз копіювати елементи поокремо. Якщо ми до контактів додамо нове поле
	    //Наприклад Други номер, то прийдеться всюди шукати такі місця в коді як тут і їх виправляти
	    //Треба подумати як це обійти (це стосується коменту про дублювання даних з початку файла)
            lastN := list^.date.lastN;
            firstN := list^.date.firstN;
            numberTell := list^.date.numberTell;
        end;
        write(tfile, z);
        list := list^.next;
    end;
    


    // if queue = Nil then
    // begin
    //     writeln('Empty!!!');
    //     exit;
    // end;

    // while queue <> Nil do
    // begin
    //     writeln(queue^.lastN, ' ', queue^.numberTell);
    //     queue := queue^.next;
    // end;

end;


procedure ShowContakt();
var 
    z: myrecord;
begin
    if filesize(tfile) = 0 then
    begin
        writeln('Телефонна книга пуста!');
        exit;
    end;
    writeln('Ваш список контактів:');
    seek(tfile, 0);
    while not eof(tfile) do
    begin
        read(tfile, z);
        writeln(z.firstN, ' ', z.lastN, ' ', '+380', z.numberTell);
    end;
    // writeln(filepos(tfile));
end;


procedure SearchLastName();
var
    z: myrecord;
    tmp: string;
begin
    readln(tmp);
    seek(tfile, 0);
    while not eof(tfile) do
    begin
        read(tfile, z);
        if z.lastN = tmp then
        begin
            writeln(z.lastN, ' ', z.firstN, ' ', '+380', z.numberTell);
            writeln(filepos(tfile));
            exit;
        end;  
    end;

    if z.lastN <> tmp then
    begin
        write('Contact not found');
        exit;
    end;
end;


procedure SearchNumberTell();
var
    z: myrecord;
    tmp: int64;
begin
    write('Введіть номер телефону: ');
    readln(tmp);
    seek(tfile, 0);
    while not eof(tfile) do
    begin
        read(tfile, z);
        if z.numberTell = tmp then
        begin
            writeln(z.lastN, ' ', z.firstN, ' ', '+380', z.numberTell);
            exit;
        end;
    end;

    if z.numberTell <> tmp then
    begin
        writeln('Contact not found');
        exit;
    end;
end;


//Код робочий і це пиздато. Загалом, я задоволений. Деякими моментами я вражений. Але пару косячків треба переробити
begin
    {$I-}
    assign(tfile, 'booksTell.txt');
    reset(tfile);

    if IOResult <> 0 then
    begin    
        rewrite(tfile);
        writeln('File creat');
    end;
    while True do
    begin
        writeln ('1: Показати список контактів');
        writeln ('2: Додати контакт');
        writeln ('3: Показати контакт по номеру');
        writeln ('4: Сортувати за прізвищем');
        writeln ('5: Видалити за номером');
        readln(vibor);
        case vibor of            
            1: ShowContakt();
            2: AddContakt();
            3: SearchNumberTell();
            4: SortArrayLast();
            5: DellContakt();
        end;
    end;
    close(tfile);
end.