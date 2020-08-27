program md7;
uses crt, dos;
{preciizi nestraadaa saraksts, ja atfiltree un tad lapo, bet nu bez taa var iztikt vai pielabot}
const
    per_page : byte = 20;{noraada cik vienaa reizee rindas raadaas}
    menu_size : byte = 5;{cik daudz izveelnee zari}
    col_len : array[1..4] of integer = (19,20,20,15);{cik katra ievades veertiiba var buut gara}
    menu_items : array[1..5] of string[10] = ('List',
                                            'Create',
                                            'Find',
                                            'Save',
                                            'Quit'); {izveelnes zari}
type
    doctor = record{definee jaunu mainiigaa tipu doctor, kam ir dazhaadi atribuuti(id,u.c.)}
           id : integer; {lai vareetu sakaartotaa sarakstaa noteikt reaalo vietu ieksh doctors}
           first_name : string[19];{sheit garumiem jaaatbilst tam kas noraadiit ieksh col_len}
           last_name : string[20];
           speciality : string[20];
           time : string[15];
    end;
    doctors_list = Array[0..100] of doctor; {jauns tips, kas apziime aarstu sarakstu}
var
   key: char; {galvenajaa programmaa nosaka kaads taustins nospiests}
   default_file,filter_value : string; {faila nosaukums un filtra veertiiba}
   {dazhaadi mainiigie}
   index, current_command,filter_column,total_rows,page_nr,total_pages : integer;
   doctors : doctors_list;{pamata saraksts, ko ielasa no faila}
   temp_arr: doctors_list;{saraksts ko izmanto, kad tiek kaartoti ieraksti}
   page: array[0..21] of doctor;{saraksts prieksh vienas lapas}
procedure OpenFile(var filename : string);{atver un ielasa failu, padotajam faila nosaukumam}
var
     current_file : text;
begin
     assign(current_file, filename);{faila saturs buus current_file}
     reset(current_file);{atver lasiishanai}
     index:=-1;{noraada cik ieraksti ir ielasiiti, peec cikla buus vismaz 0}
     while not SeekEof(current_file) do{meklee beigas}
     begin
         Inc(index);
         doctors[index].id:=index;
         readln(current_file, doctors[index].first_name);
         readln(current_file, doctors[index].last_name);
         readln(current_file, doctors[index].speciality);
         readln(current_file, doctors[index].time);
     end;
     close(current_file);{aizver failu}
end;
procedure ShowMenu;{paraada izveelni}
var
   i : integer;
begin
     clrscr;
     for i:=1 to menu_size do{ciklaa njem visu no menu_items un raada}
     begin
     {sleedzelee kraasas; dzeltena ir taa kura ir izveeleta citas baltas}
          if i = current_command then TextColor(Yellow) else TextColor(White);
          gotoxy(30,9+i);
          writeln(menu_items[i]);
     end;
end;
procedure HideCursor;{nosleepj kursoru,njemts no parauga}
{iespeejams vajag arii paraadiit pie ievades, bet man bija slinkums pielikt show}
{tas ir arii atrodams paraugaa}
var
   regs:registers;
begin
     regs.ax:=$0100;
     regs.cx:=$2607;
     intr($10,regs); {no parauga nemts}
end;
{prasa ievadiit tekstu, maksimaali padotajaa garumaa}
{priekshaa uzraksta padoto virsrakstu un viss tas novietojas padotajaa rindaa}
function ReadValue(title : string; max_len : integer; row : integer):string;
var
   i, start_col : integer;
   temp_key : char;{sheit ielasa vienu simbolu}
   value : string;
begin
     i:=0;
     write(title);{izvada virsrakstu}
     start_col:=Length(title)+1;{saakumaa noviet kursoru vienu simbolu aiz virsraksta}
     value:='';
     temp_key:=chr(250);   {saakuma simbols ir kkaads kreisais, taapat vien}
     while Ord(temp_key) <> 13 do {prasa ievadiit lidz nospiezh enter}
     begin
          temp_key:=ReadKey; {prasa nospiest taustinju}
          if i<max_len then {var uzrakstiit tikai tad ja nav pa garu }
            {ievadiit var to kas atbilst 7 uzdevumam }
             if (temp_key='-') or (temp_key=':') or (Ord(temp_key)=32) or ((temp_key>='a') and (temp_key<='z')) or
             ((temp_key>='A') and (temp_key<='Z')) or ((temp_key>='0') and (temp_key<='9')) then
             begin
               Inc(i);
               value:=value+temp_key;
             end;
          case Ord(temp_key) of
          8 : begin {ja backspace nospiests tad peedeejo simbolu uztaisa par atstarpi, ja nav 0}
                   if i>0 then 
                   begin
                       value[i]:=' ';
                       dec(i);
                   end
                   else
                       value:='';
              end;
          end;
          gotoxy(start_col,row);
          write(value); {izvadu kopeejo ievadi}
          gotoxy(start_col+i,row);
          value:=copy(value,0,i);{lai nebuutu gljuks pie dzeeshanas }
     end;
     writeln; {kad nospiests enter paariet jaunaa rindaa un gaida}
     ReadValue:=value;
end;
procedure Create; {Izveidot jaunu aarstu}
var
     new_doctor : doctor;
begin
     clrscr;
     {viss notiek caur ReadValue, kas prasa ievadiit veertiibu}
     {lai neko nesachakareetu, izveido pagaidu aarstu, kuraa notiek visa ievade}
     new_doctor.first_name:=ReadValue('First name: ',col_len[1],1);
     new_doctor.last_name:=ReadValue('Last name: ',col_len[2],2);
     new_doctor.speciality:=ReadValue('Speciality: ',col_len[3],3);
     new_doctor.time:=ReadValue('Time: ',col_len[4],4);
     {ja pagaidu aarsta visi atribuuti ir normaali, tas ir, nav tukshi, tad saglabaa reaalajaa masiivaa}
     if (new_doctor.first_name<>'') and (new_doctor.last_name<>'') and (new_doctor.speciality<>'') and
     (new_doctor.time<>'') then
     begin

          Inc(index); {par vienu aarstu vairaak}
          new_doctor.id:=index; {tas ir arii vinja id}
          doctors[index]:=new_doctor; {ieraksta galvenajaa masiivaa}
          TextColor(Green);
          writeln('New doctor successfully created!');
     end
     else
     begin
          TextColor(Red);
          writeln('Not created!');
     end;
     TextColor(White);
     ReadKey;
end;
procedure Edit(id:integer);{Labo to aarstu, kura id ir padots}
var
   new_doctor:doctor;
begin
     clrscr;
     if id>0 then {var labot tikai, ja taads aarsts eksistee}
     begin
       {viss taapat kaa Create, ievade notiek prieksh pagaidu aarsta}
       new_doctor.first_name:=ReadValue('First name:'+'('+doctors[id].first_name+') ',col_len[1],1);
       new_doctor.last_name:=ReadValue('Last name:'+'('+doctors[id].last_name+') ',col_len[2],2);
       new_doctor.speciality:=ReadValue('Speciality:'+'('+doctors[id].speciality+') ',col_len[3],3);
       new_doctor.time:=ReadValue('Time:'+'('+doctors[id].time+') ',col_len[4],4);
       {ja kkas ir izlabots NB! taa ir atshkjiriiba no Create}
      if (new_doctor.first_name<>'') or (new_doctor.last_name<>'') or (new_doctor.speciality<>'') or
      (new_doctor.time<>'') then
       begin
            new_doctor.id:=id; {kopeejam visas veertiibas uz pagaidu aarstu}
            {iznjemot taas kas ir mainiitas}
            if new_doctor.first_name='' then new_doctor.first_name:=doctors[id].first_name;
            if new_doctor.last_name='' then new_doctor.last_name:=doctors[id].last_name;
            if new_doctor.speciality='' then new_doctor.speciality:=doctors[id].speciality;
            if new_doctor.time='' then new_doctor.time:=doctors[id].time;
            doctors[id]:=new_doctor; {saglabaajam}
            TextColor(Green);
            writeln('Doctor successfully changed!');
       end
       else
       begin
            TextColor(Red);
            writeln('Not changed!');
       end;
       TextColor(White);
       ReadKey;
     end;
end;
procedure ClearPage; {notiira lapu}
{vajadziigs, lai nebuutu nepareizu aartu, ja paarshkjir lapu}
var i : byte;
begin
     for i:=0 to per_page do
     begin
          page[i].id:=0;
          page[i].first_name:='';
          page[i].last_name:='';
          page[i].speciality:='';
          page[i].time:='';
     end;
end;
{Izvada aarstu sarakstu, kas tiek padots, veel padod tekosho rindu un aili}
procedure List(arr:Array of doctor;current_row : byte; current_col : byte);
var
   i,p,x : integer;
   temp_doctor : array[1..4] of string; {pagaidu aarsts, lai vareetu eerti ciklaa izvadiit ko vajag}
   header : array[1..4] of string; {galvene}
begin
     clrscr;
     write(chr(201)); {visi shitie veido skaisto tabulu}
     for i:=1 to 4 do
     begin
         for p:=1 to col_len[i] do {uzziimee augsheejo malu}
             write(chr(205));
         if i<>4 then write(chr(203));
     end;
     write(chr(187));
     writeln;
     header[1]:='        Name       ';
     header[2]:='      Surname       ';
     header[3]:='     Speciality     ';
     header[4]:='   Work hours  ';
     for i:=1 to 4 do {uzziimee galveni}
     begin
         write(chr(186));
         if current_col=i then TextColor(LightBlue) else TextColor(White) ;
         write(header[i]);
         TextColor(White);
     end;
     write(chr(186));
     writeln;
     write(chr(204));
     for i:=1 to 4 do {ziimee veel kkaadus simbolus}
     begin
         for p:=1 to col_len[i] do
             write(chr(205));
         if i<>4 then write(chr(206));
     end;
     write(chr(185));
     for i:=0 to High(arr) do {veido sarakstu}
     begin
          if arr[i].first_name<>'' then {izvadu tikai ja aarsts eksistee}
          begin {katraa gaajienaa temp_doctor tiek paarakstiits}
               temp_doctor[1]:=arr[i].first_name; 
               temp_doctor[2]:=arr[i].last_name;
               temp_doctor[3]:=arr[i].speciality;
               temp_doctor[4]:=arr[i].time;
               writeln;
               write(chr(186));
               x:=1;
               for p:=1 to 4 do
               begin {ja vajag tad ieziimee, ja ne tad izvada baltu}
                    if current_row=i then TextColor(Yellow) else TextColor(White);
                    write(temp_doctor[p]);
                    if current_row=i then TextColor(White);
                    x:=x+col_len[p]+1;
                    gotoxy(x,i+4);
                    write(chr(186));
               end;
          end
          else
              break;
     end;
     writeln;
     write(chr(200));
     for i:=1 to 4 do
     begin {izvada apaksheejo liiniju}
         for p:=1 to col_len[i] do
             write(chr(205));
         if i<>4 then write(chr(202));
     end;
     write(chr(188));
     TextColor(7); {izvada visas pieejamaas opcijas}
     {Ir pieejams viss tas pats, kas galvenajaa izveelnee, iznjemot iziet}
     writeln;
     writeln('      Edit - Enter | Destroy - Backspace | Sort - Space');
     writeln('      Scroll - <>  | Find - f | Save - s | Create - c | Back - Esc');
     TextColor(White);
     {Viens no uzdevumiem bija izvadiit skaitu, cik daudz ir atlasiiti kkas tur}
     if(filter_column>0) and (filter_value<>'') then {tikai ja ir kkas atlasiits}
         writeln('      Filtred doctors count: ',total_rows);
end;
{Kaartoshana, padotajam masiivam, peec padotaas kolonnas, un vai dilstoshi vai nee}
{Izmanto burbulja kkartoshanas algoritmu - visvienkaarshaakais}
procedure Sort(var arr : Array of doctor; col : byte;descending:boolean);
var i, j, last : integer;
          temp : doctor;
          need_swap : boolean;

begin
     for i:=low(arr) to high(arr) do {padoto masiivu kopee ieksh temp_arr}
         if arr[i].first_name<>'' then
            begin
            temp_arr[i]:=arr[i]  ;
            last:=i;
            end
         else
             break;

    for i:=last downto 0 do {sheit notiek kaartoshanas}
        for j:=1 to i do
        begin
            need_swap:=false;
            case col of
            1: need_swap :=(temp_arr[j-1].first_name > temp_arr[j].first_name);
            2: need_swap :=(temp_arr[j-1].last_name > temp_arr[j].last_name);
            3: need_swap :=(temp_arr[j-1].speciality > temp_arr[j].speciality);
            4: need_swap :=(temp_arr[j-1].time > temp_arr[j].time);
            end;
            if (descending and not need_swap) or (not descending and need_swap) then
            begin
                 temp:=temp_arr[j-1];
                 temp_arr[j-1]:=temp_arr[j];
                 temp_arr[j]:=temp;
            end;
        end;
 {proceduura neko neizvada tikai sakaarto temp_arr, ko izmanto citas proceduuras}
end;
{Dzeesh aarstu ar padoto id, no galvenaa,nesakaartotaa masiiva}
procedure Destroy(id : integer);
var i : integer;
begin
     for i:=id to index-1 do
     begin
          if doctors[i].first_name<>'' then
          begin
             doctors[i]:=doctors[i+1];
             doctors[i].id:=i;
          end;
     end;
     doctors[index].first_name:='';
     doctors[index].last_name:='';
     doctors[index].speciality:='';
     doctors[index].time:='';
     doctors[index].id:=-1;
     Dec(index);
end;
{Funkcija atgriezh veertiibu}
{Ja iesleegts filtrs, tad nosaka vai konkreetais aarsts atbilst kriteerijiem}
function IsGood(doc: doctor):boolean;
begin
     if (filter_value<>'') and (filter_column>0) then
        case filter_column of
             1: IsGood:=(doc.first_name=filter_value);
             2: IsGood:=(doc.last_name=filter_value);
             3: IsGood:=(doc.speciality=filter_value);
             4: IsGood:=(doc.time=filter_value);
        end
     else
         IsGood:=true; {ja filtrs nav iesleegts tad visis atbilsts}
end;
{Skaita cik aarstu ir pieejami, tas ir, cik atbilst kriteerijiem}
function Count(sorted:boolean):integer;
var i,c:integer;
begin
     c:=0;
     for i:=0 to index do
          if sorted  then
          begin
             if IsGood(temp_arr[i]) then inc(c)  ;
          end
          else
          begin
             if IsGood(doctors[i]) then inc(c);
          end;
     Count:=c;
end;
{Atlasa aarstus vienai lapa, jaazin vai vajag atlasiit sakaartotos vai nee}
function GetPage(sorted:boolean):integer;
var
i,counter,temp : integer;
searching: boolean;
begin
     counter:=0;
     temp:= Round(total_rows/per_page) ;{izreekjina veertiibu,  kas vareetu buut lapu skaits}
     {taa kaa neatradu nevienu funkciju kas noapaljotu uz augshu tad naacaas improvizeet}
     {skataas vai decimaalaa dalja lielaaka par 0, un mazaaka par 0.5, ja ir tad apaljo uz augshu}
     {jaaskataas vai mazaaka par 0.5, jo Round pats apaljo uz augshu no 0.5}
     if ((frac(total_rows/per_page)>0) and (frac(total_rows/per_page)<0.5))  then inc(temp);
     total_pages:=temp;
     {ja gadijumaa tekoshaa lapa lielaaka par kopeejo lapu skaitu, tad tekooshaa ir peedeejaa lapa}
     if total_rows<page_nr*per_page then page_nr:=total_pages;
     i:=(page_nr-1)*per_page; {saakuma ieraksta indekss}
     ClearPage;
     searching:=true;
     while searching do
     begin
          {ja ir sakaartots saraksts tad njem no viena, ja ne tad no galvenaa}
          if sorted then page[counter]:=temp_arr[i] else page[counter]:=doctors[i];
          if (counter+1>=per_page) or (page[counter].first_name='') then searching:=false;
          if IsGood(page[counter]) and (searching) then      {ja neatbils filtram tad iztiira}
              Inc(counter)
          else
          begin
              page[counter].first_name:='';
              page[counter].last_name:='';
              page[counter].speciality:='';
              page[counter].id:=-1;
              page[counter].time:='';
          end;
          Inc(i);
     end;
     GetPage:=counter-1; {atgriezh ierakstu skaitu laapaa,ir jeega ja ir mazaak par 20}
end;
procedure Find; {mekleeshanas uzstaadiishana}
var choice:string;
code:integer;
begin
    {izvada iespeejas, prasa ievadiit kolonnas nr, ja to ievada tad arii veertibu}
    clrscr;
    writeln('1: First Name');
    writeln('2: Last Name');
    writeln('3: Speciality');
    writeln('4: Work hours');
    writeln;
    write('Search in column: ');
    readln(choice);
    val(choice,filter_column,code);
    if (filter_column>0) and (filter_column<5) then
    begin
         write('Search what: ');
         readln(filter_value);
    end
    else
    begin
         filter_column:=0;
         filter_value:='';
    end;
    {Neko citu nedara, filtrus izmanto citas proceduuras un funkcijas}
end;
{Saglabaa padotajaa failaa}
{Lai atbilstu uzdevuma kriteerijiem, vajag varee saglabaat failaa arii sakaartotus aarstus}
{To var izdariit sakaartojot un saglabaajot no saraksta, nevis no galvenaas izveelnes}
{No galvenaas izveelnes vienmeer buss nesakaartots}
procedure Save(var filename:string;sorted:boolean);
var i:integer;
    current_file:text;
    current_doctor:doctor;
begin
     {Ja saglabaa no saraksta, tad ja ir sakaartots, failaa tiks ierakstiits sakaartoti dati}
     assign(current_file,filename);
     rewrite(current_file);{Atver rakstiishanai}
     {Ljoti liidziigi ielasiishanai, tikai failu atver raksiishanai}
     for i:=0 to index do
     begin
         if sorted then current_doctor:=temp_arr[i] else current_doctor:=doctors[i];
         writeln(current_file,current_doctor.first_name);
         writeln(current_file,current_doctor.last_name);
         writeln(current_file,current_doctor.speciality);
         writeln(current_file,current_doctor.time);
     end;
     close(current_file);
     TextColor(Green);
     gotoxy(15,27);
     writeln('File (/',filename,') successfully saved!');
     TextColor(White);
     Readkey;
end;
{Galvenaa fiicha shajaa programmaa, pats SAALS }
{Raada sarakstu un ljauj ar to opereet}
procedure ListObserver(arr:Array of doctor);
var i, current_row, current_col,last_row : byte;
temp_key : char;
descending,sorted: boolean;
begin
     current_row:=0;
     current_col:=1;
     page_nr:=1;
     descending:=false;
     sorted:=false;
     ClearPage;
     total_rows:=Count(sorted); {Izskaita cik ir kopaa}
     last_row:=GetPage(sorted); {Izreekjina lapu,taalaak ieksh page mainiigaa buus lapas aarsti}
     while Ord(temp_key)<>27 do {Ja nospiezh Esc tad iziet uz galveno izveelni}
     begin
          List(page, current_row, current_col); {Uzziimee sarakstu ar tekosho lapu}
          temp_key:=ReadKey;  {Gaida ievadi, vienu simbolu}
          case Ord(temp_key) of {Skataas kas ievadiits}
          8 : begin {Backspace - dzeesh}
                   Destroy(page[current_row].id); {Izdzeesh}
                   total_rows:=Count(sorted); {jaapaarskaita, jo mainaas kopeejais skaits}
                   if sorted then {Ja ir bijis sakaartots tad sakaarto}
                   begin
                      Sort(doctors,current_col,not descending);
                      last_row:=GetPage(true);
                   end
                   else
                      last_row:=GetPage(false);
                   if last_row>current_row then current_row:=last_row;

              end;
          13 : begin {Enter - labot}
                    Edit(page[current_row].id); {Labot tekoshaas rindas ierakstu}
                    last_row:=GetPage(sorted); {Ielasa lapu pa jaunam, lai redzeetu izmainiitaas vertiibas}
               end;
          {naakamie chektri ir bultas }
          72 : if current_row=0 then current_row:=last_row else Dec(current_row);
          75 : if current_col=1 then current_col:=4 else Dec(current_col);
          77 : if current_col=4 then current_col:=1 else Inc(current_col);
          80 : if current_row=last_row then current_row:=0 else Inc(current_row);
          32 :  begin {Space - kaarto}
                     Sort(doctors,current_col,descending); {Sakaarto}
                     {Nomaina virzienu prieksh naakamaas reizes}
                     if descending then descending:=false else descending:=true;
                     last_row:=GetPage(true);{Ielasa jauno lapu}
                     sorted:=true;
                end;
          102,72 : begin {F,f - Filtree}
                     Find;{Uzstaada filtru}
                     total_rows:=Count(sorted); {Izskaita cik tad ir taadi ieraksti}
                     last_row:=GetPage(sorted); {Atlasa vienu lapu ar taadiem ierakstiem}
                end;
          60 :  begin {< Paarskjir lapu atpakalj}
                     if page_nr>1 then Dec(page_nr); 
                     last_row:=GetPage(sorted); {Ielasa jauno lapu}
                     current_row:=0;
                end;
          62 :  begin {> Paarshkjir lapu uz priekshu}
                     Inc(page_nr);
                     last_row:=GetPage(sorted);
                     current_row:=0;
                end;
          115,83:  Save(default_file,sorted); {S,s - saglabā, arii sakaartotu, ja ir sakaartots}
          67,99: begin {C,c - Izveido jaunu}
                      Create;{Prasa izveidot}
                      total_rows:=Count(sorted); {Ielasa jauno kopeejo skaitu, to vajag}
                      {jo var buut ka pirms tam ir bijis filtrs, tad tas arii attiecas uz jauno ievadiito}
                      last_row:=GetPage(sorted);{Dabuu tekosho lapu pa jaunam}
                 end;
          end;
     end;
end;
begin {Galvenaa programmas dalja - kjermenis}
    HideCursor; {Nosleepj kursoru}
    index:=0;
    default_file:='a/arsti.dat'; {Faila nosaukums kuraa atrodas aarsti, var buut jebkaads}
    OpenFile(default_file); {Ielasa aarstus, buus kljuuda, ja fails neeksistees}
    current_command:=1;
    filter_column:=0; {Filtrs saakumaa nav}
    filter_value:='';
    while true do {Kameer nav nospiests Esc}
    begin
         ShowMenu; {Paraada izveelni}
         key:=ReadKey; {Gaida ievadu}
         if Ord(key)=27 then Exit;{Esc - iziet}
         if (Ord(key)=13) then {Enter - ieiet izveelnee}
         begin
            case current_command of {Kuraa izveelnee iet, ir atkariigs no izveeleetaas komandas}
              1 : ListObserver(doctors);
              2 : Create;
              3 : Find;
              4 : Save(default_file,false);
              5 : Exit;
            end;
         end;
         case Ord(key) of {Ja nospiezh bultu Up vai Down tad virzaas pa izveelni}
           72 : if current_command = 1 then current_command:=menu_size else dec(current_command);
           80 : if current_command = menu_size then current_command:=1 else inc(current_command);
         end;
    end;
end.