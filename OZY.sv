`define WRITE 1   // Макроопределение WRITE определяет константу равную 1
`define READ 0    // Макроопределение READ определяет константу равную 0

module OZY
#(
      parameter word_size = 21,         // Ширина слова ОЗУ
      parameter word_quantity = 33      // Количество слов ОЗУ
)
(
      // Общая формула для определения необходимого количество битов в адресе звучит следующим образом:
      // n = log2(N), где N - это размер памяти в битах и n - количество битов в адресе.
      // В нашем случае размер памяти равен количеству слов в памяти word_quantity
      input logic [$clog2(word_quantity)-1:0] addr, // адрес обращения
      input logic we,                               // признак обращения
      input logic Type,                             // тип операции (запись/чтение)
      input logic [word_size-1:0] data_in,          // данные для записи
      output logic [word_size-1:0] data_out         // прочитанные данные
);

reg [word_size-1:0] mem [word_quantity-1:0];   // память из 33 слов, каждое по 21 бит

always @(posedge we)  // выполнение при изменении значения входного сигнала we (признака обращения)
begin
    // Блок always проверяет значение входного сигнала addr, и если его значение
    // находится в массиве, то выполняет нужную операцию
    if ((addr >= 0) && (addr <= word_quantity-1)) begin
	     // Если сигнал we установлен и не вышли за рамки адресов, подан сигнал записи, блок always записывает
        // данные из сигнала data_in в выбранный элемент массива mem, определенный адресом addr
        if (Type == `WRITE) begin   
				mem[addr] <= data_in;
        end
		  // Если сигнал we установлен и не вышли за рамки адресов, подан сигнал чтения, блок always записывает
        // данные из выбранного элемента массива mem, определенный адресом addr в сигал data_out
        else if (Type == `READ) begin    
				data_out <= mem[addr];
        end
    end
	// иначе - ошибка. Вышли за уровень диапазона адресов.
    else begin
        $display("ERROR! Out of memory range");
    end
end
endmodule