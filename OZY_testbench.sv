`include "OZY.sv"
module OZY_testbench
#(
    parameter word_size = 21,         // Ширина слова ОЗУ
    parameter word_quantity = 33      // Количество слов ОЗУ
);
    // определение исходных сигналов
    logic [$clog2(word_quantity)-1:0] addr; // адрес обращения. Управляемая переменная
    logic we;                               // признак обращения. Управляемая переменная
    logic Type;                             // тип операции (запись/чтение). Управляемая переменная
    logic [word_size-1:0] data_in;          // данные для записи
    logic [word_size-1:0] data_out;         // прочитанные данные

//Вызов задачи для чтения памяти
task automatic read_mem
(
    // входной параметр команды - адрес для чтения
    input logic [$clog2(word_quantity)-1:0] addr_prim
);
    // обращаемся к переменной. Есть сигнал обращения 
    we <= !we;
    // тип операции - запись 
    Type <= `READ;
    // установили адрес переданный для чтения в ОЗУ 
    addr <= addr_prim;
    #1;
    #1;
	// Обновляем данные в памяти, нет сигнала обращения
    we <= !we; 
    #1;
endtask

//Вызов задачи для записи в память
task automatic write_mem
(
    // входной параметр команды - адрес для чтения
    input logic [$clog2(word_quantity)-1:0] addr_prim,
    // входной параметр команды - данные, которые будем записывать
    input logic [word_size-1:0] data_prim
);
    // исходное состояние. Нет обращения 
    we <= 0;
    // тип операции - чтение 
    Type <= `WRITE;
     // установили адрес переданный для записи в ОЗУ 
    addr <= addr_prim;
    // установили данные, переданные для записи в ОЗУ
    data_in <= data_prim;
	$display("Data written to address %d: %h", addr_prim, data_prim);
    // Обновляем данные в памяти
    #1;
    // есть сигнал обращения
    we <= !we;
    #1;
    // нет сигнала обращения
    we <= !we;
	#1;
endtask

// Создание экземпляра OZY
OZY
#(
    .word_size  (word_size),
    .word_quantity(word_quantity)
) dut 
(
    .addr(addr),
    .we(we),
    .Type(Type),
    .data_in(data_in),
    .data_out(data_out)
);

// Имитация работы модуля
initial begin
     // 1-ый набор данных
     // Запись в память
     write_mem(5, 13);
     // Чтение из памяти
     read_mem(5);
     $display("Data read from address %d: %h", addr, data_out);
     // второй набор данных
     // Запись в память
     write_mem(24, 15);
     // Чтение из памяти
     read_mem(24);
     $display("Data read from address %d: %h", addr, data_out);
     // третий набор данных
     // Запись в память
     // 137_217_727 - максимальное значение, которое может быть сохранено в переменной типа
     // unsigned word_size(2^27 -1)
     write_mem(32, 134_217_727);
     // Чтение из памяти
     read_mem(32);
     $display("Data read from address %d: %h", addr, data_out);
     // третий набор данных
     // Запись в память
     write_mem(33, 19);
     $finish;
end

// создание файла .vcd и вывести значения переменных волны для отображения в визуализаторе волн
initial begin
    $dumpfile("OZY.vcd");
    $dumpvars(0, OZY_testbench);
end
endmodule