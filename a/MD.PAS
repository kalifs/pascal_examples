program md;
uses CRT, DOS;
  {konstantes izvelnes attelosanai}
const
   Menu : array[1..6] of string[14] = ('1. View       ',
                                       '2. Add        ',
                                       '3. Del        ',
                                       '4. Edit       ',
                                       '5. Search     ',
                                       '6. Exit       ');
  MenuCount = 6;  {izvelnes komandu skaits}
  MenuCharCount = 14;  {maksimalais simbolu skaits komanda}
  {konstantes ramisu attelosanai}
  VertFrame = 'º';       {vertikalas stripas kods Alt+186}
  HorzFrame = 'Í';       {horizontalas stripas kods Alt+205}
  TopRightFrame = '»';   {augsejais labais sturis kods Alt=187}
  BottomRightFrame = '¼';{apaksejais labais sturis kods Alt+188}
  BottomLeftFrame = 'È'; {apaksejais kreisais sturis kods Alt+200}
  TopLeftFrame = 'É';    {augsejais kreisais sturis}
  {konstantes, tipi un mainigie informacijas glabasanai}
  FileName = 'stud.txt';
type
  student = record
    FirstName : string[12];
    LastName : string[12];
    math : string[5];
    tep : string[1];
    engl : string[1]
  end;
  Names = string[12];
var
  st : array[1..100] of student;
  rec : student;
  count : integer;   {studentu skaits}
  CurCommand : integer;  {tekosas (iezimetas) komandas numurs}
  row,column : byte;  {kursora koordinates}
  ch : char;  {nospiestais taustins }
  p : boolean;  {tekstveida rindai atbilst true, ciparu rindai - false}
  leng : integer; {ievadita parametra garums}
  i : integer;
procedure ShowCursor;
var
  regs : registers;
begin
  regs.ax := $0100;
  regs.cx := $0506;
  intr($10, regs);
end;
procedure View;
{izvada faila saturu uz ekranu}
var
i : integer;  {globalos mainigos nav jaizmanto ciklu organizacijai}
begin
  {izvadam tabulas virsrakstu}
  ClrScr;
  gotoxy(5,1);
  write('List of students:');
  gotoxy(1,2);
  for i:=1 to 55 do write(HorzFrame);
  gotoxy(2,3);
  write('N');
  gotoxy(4,3);
  write('FirstName');
  gotoxy(22,3);
  write('LastName');
  gotoxy(42,3);
  write('Math');
  gotoxy(47,3);
  write('Tep');
  gotoxy(52,3);
  write('Engl');
  gotoxy(1,4);
  for i:=1 to 55 do write(HorzFrame);
  {izvadam studentu sarakstu}
  for i:=1 to count do
  begin
    gotoxy(1, 4+i);
    ClrEol;
    gotoxy(1, 4+i);
    write(i:2,'. ');
    gotoxy(4, 4+i);
    write(st[i].FirstName);
    gotoxy(23, 4+i);
    write(st[i].LastName);
    gotoxy(43, 4+i);
    write(st[i].math);
    gotoxy(48, 4+i);
    write(st[i].tep);
    gotoxy(53, 4+i);
    write(st[i].engl);
  end;
 { ch:=ReadKey; }
end;
procedure InputData(var Name : string; leng : integer; p:boolean);
{nodrosina datu ievadi un aizsardzibu pret kludam}
var
  i,k,len : integer;
  ch : char;
  CopyName : string;
begin
  for i:=1 to leng do
  Name[i]:=' ';
  Name[0]:=chr(leng);
  i:=1;
  ShowCursor;
  while true do
  begin
    ch := ReadKey;
    {ja ir nospiests vadibas taustins}
    if Ord(ch)=0 then
    begin
      ch := ReadKey;
      continue
    end;
    {ja ir ievadits burts vai cipars}
    if((ch >= 'A') and (ch <= 'Z') or (ch >= 'a') and (ch <= 'z') or
    (ch = '_') or (Ord(ch) = 32)) and p
    or ((ch >= '0') and (ch <= '9') or (ch = ':') or (ch = '.')) and
    not p then
    begin
      {ja rinda Name nav vietas jaunajam simbolam}
      if(i>leng) and (Ord(ch) <> 8)then
      begin
        write(Chr(7));  {izvadit skanas signalu}
        continue;
      end;
      {ja pirmais ir mazais burts, parveidosim to lielaja burta}
      if(i=1)then ch:=UpCase(ch)
      else if(ch >= 'A') and (ch <= 'Z') then ch:=Chr(Ord(ch)+32);
      write(ch);
      {ierakstam ievaditu simbolu rinda Name}
      Name[i]:=ch;
      i:=i+1;
    end;
    {ja ir nospiests <Enter> un vismaz 1 simbols tika ievadits}
    if(Ord(ch)=13) and (i>1) then break;
    {ja ir ievaditi simboli un nospiests <BackSpace>}
    if (i>1) and (Ord(ch) = 8) then
    begin
      i:=i-1;
      Name[i]:=' ';
      {dzesam simbolu no ekrana un parvietojam kursoru}
      gotoxy(Wherex-1, Wherey);
      write(' ');
      gotoxy(Wherex-1, Wherey);
    end
  end;
  {dzesam tuksumzimes ciparu rinda}
  if not p then
  begin
    len := 0;
    for i:= 1 to ord(Name[0]) do
    if Name[i] <> ' ' then
    begin
      len := len + 1;
      CopyName[len] := Name[i]
    end;
    CopyName[0] := chr(len);
    Name := CopyName
  end
end;
procedure Add;
{pievieno jaunu ierakstu}
var
str : string;
begin
  ClrScr;
  gotoxy(1,2);
  TextBackground(Blue);
  TextColor(Yellow);
  write('Input name: ');
  TextColor(Black);
  TextBackground(Cyan);
  write('     ');
  gotoxy(13,2);
  leng:=5;
  InputData(str,leng,true);
  st[count].FirstName:=str;
  gotoxy(20,10);
  write('Procedura Add');
  TextColor(Black);
  TextBackground(Cyan);
  gotoxy(20,14);
  write('Name=',str);
  count:=count+1;
  ch:=ReadKey
end;
procedure Del;
{dzes kadu no ierakstiem}
begin
  ClrScr;
  gotoxy(20,10);
  write('Procedura Del');
  ch:=ReadKey
end;
procedure Edit;
{redige ieraksta satury}
begin
  ClrScr;
  gotoxy(20,10);
  write('Procedura Edit');
  ch:=ReadKey
end;
procedure Search;
{dod iespeju atrast informaciju par konkretu studentu}
begin
  ClrScr;  {tiram ekranu}
  gotoxy(20,10);  {parvietojam kursoru}
  writeln('Procedure Search');
  ch := ReadKey;
end;
procedure Load;
var
  fv :text;
begin
  assign(fv,FileName);
  reset(fv);
  count := 1;
  while not SeekEof(fv) do
  begin
    readln(fv, St[count].FirstName);
    readln(fv, St[count].LastName);
    readln(fv, St[count].math);
    readln(fv, St[count].tep);
    readln(fv, St[count].engl);
    count := count+1
  end;
  count := count - 1;
  close(fv);
end;
procedure HideCursor;
var
  regs : registers;
begin
  regs.ax := $0100;
  regs.cx := $2607;
  intr($10, regs);
end;
procedure Izvelne;
var
  i:integer;
begin
    TextBackground(Blue);  {noradam fona krasu}
    TextColor(Yellow);  {noradam teksta krasu}
    ClrScr;
    HideCursor;
    {izvadam izvelni uz ekranu}
    row := 5;
    column := 30;
    for i:= 1 to MenuCount do
    begin
      gotoxy(column, row+i-1);  {parvietojam kursoru}
      if i=CurCommand then
        begin
          write(VertFrame);
          TextBackground(Cyan);
          TextColor(Black);
          write(Menu[i]);
          TextBackground(Blue);
          TextColor(Yellow);
          write(VertFrame)
        end
      else write(VertFrame, Menu[i], VertFrame);
    end;
    {izvadam ramisa horizontalas linijas}
    {no sakuma augseju}
    gotoxy(column, row-1);
    write(TopLeftFrame);
    for i:=1 to MenuCharCount do
    write(HorzFrame);
    write(TopRightFrame);
    {un tagad apakseju}
    gotoxy(column, row+MenuCount);
    write(BottomLeftFrame);
    for i:=1 to MenuCharCount do
    write(HorzFrame);
    write(BottomRightFrame);
end;
begin
  Load;
  CurCommand := 1;  {tekosas (iezimetas) komandas numurs}
  {kamer netiks izvelets 6. punkts, tiks izpildits bezgaligais cikls}
  while true do
  begin
    Izvelne;
    {nosakam, kads taustins ir nospiests}
    ch:=ReadKey;
    {ja ir nospiests taustins <Esc>, partraucam programmas darbibu}
    if Ord(ch)=27 then Exit;
    {ja ir nospiests vadibas taustins vai taustins <Enter>}
    if (Ord(ch)=0) or (Ord(ch)=13) then
    begin
      {nosakam nospiestu taustinu}
      if Ord(ch) <> 13 then ch:=ReadKey;
      case Ord(ch) of
           {ja ir nospiesta bultina uz leju}
        80:if CurCommand < MenuCount then CurCommand:=CurCommand+1
           else CurCommand:=1;
           {ja ir nospiesta bultina uz augsu}
        72:if CurCommand > 1 then CurCommand:=CurCommand-1
           else CurCommand:=MenuCount;
           {ja ir nospiests taustins <Enter>}
        13:case CurCommand of
             1:begin
                  View;
                  ch:=ReadKey
               end;
             2:Add;
             3:Del;
             4:Edit;
             5:Search;
             6:Exit;
           end
      end
    end
  end
end.
