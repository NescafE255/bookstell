program booktell;

type
    rec = ^myrecord;
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
    //rec наприклад. Транслітерація
    zapis: myrecord;
    choice: integer;
    list: listed;

procedure ListPut(var list: listed);
var
    first, tmp: listed;
begin
    new(first);
    //Якщо ми додамо в структуру ще якийсь елемент (дату народження наприкла)
    //то нам прийдеться тут робити зміни. А ми можемо забути і буде бага. Для того і поле date було додано
    //first^.date = zapis не буде працювати?
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

//Варто перейменувати
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
        ListPut(list);
    end;
end;

//Contact
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
    arr: Array of rec;
    z: rec;
    i, j: byte; 
    used_elements: integer;
    tmp: rec;

begin
    if filesize(tfile) = 0 then
    begin
        writeln('Телефонна книга пуста!');
        exit;
    end;

    used_elements := 0;
    seek(tfile, 0);
    SetLength(arr, filesize(tfile));
    while not eof(tfile) do
    begin
        new(z);
        read(tfile, z^);
        arr[used_elements + 1] := z;
        inc(used_elements)
    end;

    for i:= 1 to used_elements-1 do
        for j:= 1 to used_elements-i do
        begin
            if arr[j]^.lastN > arr[j+1]^.lastN then 
            begin
                tmp := arr[j];
                arr[j] := arr[j+1];
                arr[j+1] := tmp;
            end;
        end;
    //Винести в окрему функцію. Це є закінчена логічна операція. І постійно її писати не варіант
    for i := 1 to used_elements do
    begin
        writeln(arr[i]^.lastN, ' ', arr[i]^.firstN,' ' ,' +380' ,arr[i]^.numberTell);
        Dispose(arr[i]);
    end;
    
end;

//Contact
procedure DellContakt();
var
    z: myrecord;
    search: int64;
    pos: integer;
    //непотрібний флажок. Ти можеш перевіряти чи номер знайдений по pos
    flag: boolean;
begin
    write('Введіть номер: +380');
    readln(search);
    seek(tfile, 0);
    flag := False;
    while not eof(tfile) do
    begin
        read(tfile, z);
        if search = z.numberTell then
        begin
            pos := filepos(tfile);
            flag := True;
        end;
    end;
    if flag = False then
    begin
        writeln('Номер не знайдено!');
        exit;
    end;

    seek(tfile, 0);
    //вартує перейменувати функцію, бо по назві не зрозуміло що вона робить
    AddListed();
    close(tfile);

    //Mid має бути, треба перейменувати
    DelletMi(pos-1);

    rewrite(tfile);
    while list <> Nil do
    begin
        with z do
        begin
	    //Ми повинні кожен раз копіювати елементи поокремо. Якщо ми до контактів додамо нове поле
	    //Наприклад Други номер, то прийдеться всюди шукати такі місця в коді як тут і їх виправляти
	    //Треба подумати як це обійти (це стосується коменту про дублювання даних з початку файла)
        //Комент досі актуальний. z = list^.date не буде працювати?
            lastN := list^.date.lastN;
            firstN := list^.date.firstN;
            numberTell := list^.date.numberTell;
        end;
        write(tfile, z);
        list := list^.next;
    end;
    
end;

//ShowContacts, бо ми виводимо всі контакти
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

//Не працює, треба розібратися
procedure FilterLast();
var 
    arr: Array of rec;
    z: rec;
    tmp, tmp1: string;
    i, used_elements: integer;
begin
    readln(tmp);
    seek(tfile, 0);
    SetLength(arr, filesize(tfile));
    used_elements := 0;
    while not eof(tfile) do
    begin
        new(z);
        read(tfile, z^);
        arr[used_elements + 1] := z;
        inc(used_elements);
    end;



    for i := 1 to used_elements do
    begin
        Str(arr[i]^.numberTell, tmp1);

        if pos(tmp, LowerCase(arr[i]^.lastN)) or 
        pos(tmp, LowerCase(arr[i]^.firstN)) or 
        pos(tmp, tmp1) >= 1  then
            writeln(arr[i]^.lastN, ' ', arr[i]^.firstN,' ' ,' +380' ,arr[i]^.numberTell)
    end;    
end;

//Rename
procedure RanameLastName();
var
    z: myrecord;
    _name: string; 
    _name1: string;
begin
    write('Введіть прізвище яке хочете перейменувати: ');
    readln(_name);
    seek(tfile, 0);
    
    while not eof(tfile) do 
    begin

        read(tfile, z);

        if z.lastN = _name then
        begin
            writeln('Введіть нове прізвище: ');
            read(_name1);
            seek(tfile, filepos(tfile) -1);
            z.lastN := _name1;
            write(tfile, z);
            // seek(tfile, 0);
            exit;
        end;
        
    end;

    if _name <> z.lastN then
    begin
        writeln('Contact not found');
        exit;
    end;

end;


begin
    {$I-}
    assign(tfile, 'booksTell.txt');
    reset(tfile);
    if IOResult <> 0 then
    begin    
        rewrite(tfile);
        //непотрібний рядок
        writeln('File creat');
    end;
    while True do
    begin
        writeln ('1: Показати список контактів');
        writeln ('2: Додати контакт');
        writeln ('3: Показати контакт по номеру');
        writeln ('4: Сортувати за прізвищем');
        writeln ('5: Видалити за номером');
        writeln ('6: Фільтр');
        writeln ('7: Перейменувати контакт за прізвищем');
        readln(choice);
        case choice of            
            1: ShowContakt();
            2: AddContakt();
            3: SearchNumberTell();
            4: SortArrayLast();
            5: DellContakt();
            6: FilterLast();
            7: RanameLastName();
        end;
        //writeln тут би пасував, аби всьо в купі не було на екрані
    end;


    close(tfile);

end.