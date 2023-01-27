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
    _record: myrecord;
    choice: integer;
    list: listed;

procedure ListPut(var list: listed);
var
    first, tmp: listed;
begin
    new(first);
    first^.date := _record;
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

procedure DelletMid (x: integer);
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


procedure CompletingList();
begin

    if eof(tfile) = True then
    begin
        // writeln('File empty!');
        exit;
    end;

    while not eof(tfile) do
    begin
        read(tfile, _record);
        ListPut(list);
    end;
end;


procedure AddContact();
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


procedure Output(var z: myrecord);
begin
    writeln(z.lastN, ' ', z.firstN, ' ', '+380', z.numberTell);
end;

procedure OutputArr(var arr: Array of rec; couter: integer);
begin
    writeln(arr[couter]^.lastN, ' ', arr[couter]^.firstN,' ' ,' +380' ,arr[couter]^.numberTell);
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

    for i := 1 to used_elements do
    begin
        OutputArr(arr, i);
        Dispose(arr[i]);
    end;
    
end;


procedure DellContact();
var
    z: myrecord;
    search: int64;
    pos: integer;
begin
    write('Введіть номер: +380');
    readln(search);
    seek(tfile, 0);
    while not eof(tfile) do
    begin
        read(tfile, z);
        if search = z.numberTell then
        begin
            pos := filepos(tfile);
        end;
    end;

    if pos = 0 then
    begin
        writeln('Номер не знайдено!');
        exit;
    end;

    seek(tfile, 0);
    CompletingList();
    close(tfile);

    DelletMid(pos-1);

    rewrite(tfile);
    while list <> Nil do
    begin
        z := list^.date;
        write(tfile, z);
        Dispose(list);
        list := list^.next;
    end;
    //Треба видалити всі контакти з списку  (Dispose), бо лишається зайва пам'ять, яку ми більше не використовуємо
end;


procedure ShowContacts();
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
        Output(z);
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
            Output(z);
            // writeln(filepos(tfile));
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
            Output(z);
            exit;
        end;
    end;

    if z.numberTell <> tmp then
    begin
        writeln('Contact not found');
        exit;
    end;
end;

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

        if pos(LowerCase(tmp), LowerCase(arr[i]^.lastN)) or 
        pos(LowerCase(tmp), LowerCase(arr[i]^.firstN)) or 
        pos(tmp, tmp1) >= 1  then
        begin
            OutputArr(arr, i);
        end;
        Dispose(arr[i]);
    end;    
end;


procedure RenameLastName();
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
            1: ShowContacts();
            2: AddContact();
            3: SearchNumberTell();
            4: SortArrayLast();
            5: DellContact();
            6: FilterLast();
            7: RenameLastName();
        end;
        writeln
    end;


    close(tfile);

end.