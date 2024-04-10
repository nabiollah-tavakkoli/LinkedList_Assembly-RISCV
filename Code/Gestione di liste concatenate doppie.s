.data
listinput: .string "ADD(A)~ADD(b)~ADD(C)~ADD(a)~ADD(B)~ADD(c)~ADD(,)~ADD(.)~ADD(;)~ADD(1)~ADD(2)~ADD(3)~AD D({)~ADD(d)~ADD(e)~SORT~REV~DEL(d)~DEL(e)~ PRINT"
nonEsiste: .string "\ntale elemento da eliminare non esiste nella lista\n"
empty_linkedList: .string "\nDoubly_linked_list is currently empty\n"
empty: .string "\n ListInput is empty "
newline: .string "\n"
line: .string "   |   "
fine: .string "\nEND"
arr: .byte 100            #arrayaddress

.text

main:
    lw s4, arr         # indica l'indirizzo alla testa dell'array , dove gli elementi vengono aggiunti per poter essere ordinati nel SORT
    li s2, 0x00002000  # s2 contiene l'indirizzo alla testa della linkedList
    li s3, 0xFFFFFFFF  # contiene il valore memorizzato nei primi o negli ultimi 4 byte dei nodi
    la a0, listinput
    li a2, 0xFFF
    
    li s10, 0          # indica la lunghezza della LISTA_CONCATENATA_DOPPIA, aumenta di 1 (con ogni inserimento) in ADD , decrementa di 1 (con ogni delete) in DEL   
    li s11, 0          # indica la lunghezza della listinput dopo trim

    jal trim
    add s0, a2, zero  # s0 l'indirizzi alla testa dell'array che contiene la lista dei comandi dopo trim
    bne s11, zero, split_call

listinput_is_empty:
    la a0, empty
    li a7, 4
    ecall
    j end_func
    
###########################################################
####                   TRIM method                      ###
###########################################################
trim:
    li t0, 0    # contatore della stringa ListInput
    li t5, 0    # contatore della nuova stringa
    li t4, 32   # ascii code of "space"
    li t6, 126  # registro contenente codice ASCII di Tilde (~)
is_correct_space:
    add t1, t0, a0               # l'indirizzo di ciascun carattere
    lb t2, 0(t1)                 # carica ciascun carattere in t2
    beq t2, zero, end_trim       # loop termina , se troviamo zero(null)
    bne t2, t4, concat           # se tale carattere non ? uno spazio vai a concat (concatenare)
    
    lb a1, 1(t1)
    beq a1, t6, incremento       # controlla se il carattere successivo ? ~ , allora va a incremento perch? cos? lo spazio viene eliminato (ignorato)
    lb a1, -1(t1)
    beq a1, t6, incremento       # controlla se il carattere precedente ? ~

concat:
    addi s11, s11, 1               # indica la lunghezza della listinput dopo trim                           
    add t3, a2, t5               # l'indirizzo di memoria per memorizzare il carattere (diverso dallo spazio ammesso)
    addi t5, t5, 1               # aumenta contatore della stringa risultante
    sb t2, 0(t3)                 # concatena
                                 
incremento:
    addi t0, t0, 1               # aumenta contatore della ListInput
    j is_correct_space
    
end_trim:
    jr ra


###########################################################
####                   split_cal method                 ###
###########################################################
split_call:
    li t0, 0             # l'indice a partire da cui caricare una parola oppure un byte dalla stringa
    li t1, 0             # indica la posizione della prossima "~"
funct_exists:
    add t2, t1, s0
    lb t5, 0(t2)
   
    bgt t1, s11, end_func    # se i>n vai a end_func (non ci sono altri comandi)
    addi t1, t1, 1
   
    beq t5, zero, split_loop # controlliamo se siamo alla fine della stringa , se si va a split_loop per eseguire l'ultimo comando (eventuale)
    li t6, 126              # t6 temporaneamente contiene codice ASCII di "~"
    beq t5, t6, split_loop
   
    j funct_exists
split_loop:
    sub a3, t1, t0       # a3 contiene (la lunghezza del comando) + 1
  
    add t2, t0, s0       # t2 contiene l'indirizzo del prossimo carattere nella stringa
    lw t3, 0(t2)         # t3 contiene (una parola) i primi 4 byte di un comando presente nella stringa 
    
    li t4, 675562561     # ascii code di "ADD("
    beq t3, t4, ADDeDEL_controll
    
    li t4, 676087108     # ascii code di "DEL("
    beq t3, t4, ADDeDEL_controll
    
    li t4, 1313428048     # ascii code di "PRIN"
    beq t3, t4, PRINT_controll    
    
        
    li t4, 1414680403     # ascii code di "SORT"
    beq t3, t4, SORT_controll
    
    j REV_controll        # Alla fine o ? REV oppure un comando non valido
    
incremento_split:
    add t0, t1, zero         # incrementa char_counter, char_counter = (della posizione della nuova ~) + 1 
    j funct_exists

ADDeDEL_controll:
    li a4, 7                 # a4 indica (la lunghezza di ADD(c) o DEL(c)) +1
    bne a3, a4, incremento_split # se la lunghezza non ? corretta , allora eseguire il resto ? ridondante
   
    add a0, t4, zero       # a0 contiene momentaneamente il contenuto di t4
    li t3, 32              # t3 contiene il codice ascii di "space"
    li t4, 126              # t4 contiene il codice ascii di "~"
    li t5, 41               # t5 contiene il codice ascii di ")"
    lb a1, 4(t2)           # a1 contiene il eventuale carattere da aggiungere (o rimuovere) ************ a1 ************
 
    blt a1,t3, incremento_split # controlliamo se "char" ? un carattere valido
    bge a1,t4, incremento_split
     
    lb t6, 5(t2)           # t6 dovrebbe contenere " ) "
    bne t6, t5, incremento_split
    
verifica_ADDeDEL:   
    li t3, 676087108
    blt a0, t3, ADD 
    beq a0, t3, DEL
PRINT_controll:
    li a4, 6                 # a4 indica (la lunghezza di PRINT) +1
    bne a3, a4, incremento_split # se la lunghezza non ? corretta , allora eseguire il resto ? ridondante
   
    li t3, 84              # t3 contiene il codice ascii di "T"
    lb t4, 4(t2)           # t4 dovrebbe contenere " T"
    beq t4, t3, PRINT
    
    j incremento_split
REV_controll: 
    li a4, 4                  # a4 indica (la lunghezza di REV) +1
    bne a3, a4, incremento_split # se la lunghezza non ? corretta , allora eseguire il resto ? ridondante
    
    li t3, 82              # t3 contiene il codice ascii di "R"
    lb t4, 0(t2)           # t4 dovrebbe contenere " R"
    bne t4, t3, incremento_split
  
    li t5, 22085           # t4 contiene il codice ascii di "EV"
    lh t6, 1(t2)           # t5 dovrebbe contenere " EV"
    bne t6, t5, incremento_split
  
    jal REV    
    j  incremento_split


SORT_controll:
    li a4, 5                  # a4 indica (la lunghezza di SORT) +1
    bne a3, a4, incremento_split # se la lunghezza non ? corretta , allora eseguire il resto ? ridondante
  
    j SORT
    
###########################################################
####                    LFSR method                     ###
###########################################################
LFSR:
    add a3, a2, zero
LFSR_loop:
    li t3, 0x0000FFFF
    and a4, a3, t3     # 'and' va usato per ottenere i 16-bit meno significativi dell'indirizzo corrente

    srli t3, a4, 0    # shift a destra di 0 bit
    srli t4, a4, 2    # shift a destra di 2 bit
    srli t5, a4, 3    # shift a destra di 3 bit
    srli t6, a4, 5    # shift a destra di 5 bit


    xor t3, t3, t4
    xor t3, t3, t5
    xor t3, t3, t6
    
    
     slli t3, t3, 15
     srli t4, a4, 1
    
    or a4, t4, t3    # nuovo 16-bit-LFSR generato  
    or a0, a4, s2    # a0 contiene l'inidirizzo di memoria da restituire
    add a3, a0, zero
LFSR_controll:       # controlla se tale area di memoria ? stata utilizzata oppure no
    lw t3, 0(a0)
    bne t3, zero, LFSR_loop    # Se ? uguale a zero , vuol dire non ? occupato
    lb t4, 4(a0)
    bne t4, zero, LFSR_loop
    lw t5, 5(a0)
    bne t5, zero, LFSR_loop
    
    jr ra

###########################################################
####                    ADD method                      ###
###########################################################
ADD:
addi s10, s10, 1 
bne a5, zero, con_LFSR

senza_LFSR:
    addi a5, a5, 1
    add a2, s2, zero
    sw s3, 0(a2)    # 0xFFFFFFFF viene memorizzato nei PRIMI 4 byte del nodo ESISTENTE
    j ADD_loop
    
con_LFSR:
    
    jal LFSR
    sw a0, 5(a2)   # NUOVO indirizzo viene memorizzato negli ULTIMI 4 byte del nodo ESISTENTE
    sw a2, 0(a0)   # l'indirizzo alla TESTA del nodo ESISTENTE viene memorizzato nei PRIMI 4 byte del NUOVO nodo
   
    add a2, a0, zero # il NUOVO INDIRIZZO viene memorizzato in a2

ADD_loop:
    sw a1, 4(a2)   # nuovo "char" viene memorizzato nel campo DATA del nodo
    sw s3, 5(a2)   # 0xFFFFFFFF viene memorizzato negli ULTIMI 4 byte del nodo 
    
    j incremento_split


###########################################################
####                    DEL method                      ###
###########################################################
DEL:
    add a3, s2, zero
       
find_element:
    lb t3, 4(a3)
    beq t3, a1, DEL_loop   # cerchiamo il valore da eliminare
   
    lw t4, 5(a3)           # t4 contiene l'indirizzo alla testa del prossimo nodo da controllare
    beq t4, s3, el_notExists
    
    add a3, t4, zero
    j find_element
DEL_loop:
                           # a3 contiene l'indirizzo alla testa del nodo da rimouovere
    lw t3, 0(a3)           # t3 contiene l'indirizzo alla TESTA del nodo PRECEDENTE
    beq t3, s3, DEL_testa  # se t3 contiene 0xFFFFFFFF, allora stiamo eliminando l'elemento il nodo INIZIALE della linkedList
  
    lw t4, 5(a3)          # t4 contiene l'indirizzo alla TESTA del nodo SUCCESSIVO
    beq t4, s3, DEL_coda  # se t3 contiene 0xFFFFFFFF, allora stiamo eliminando l'elemento il nodo FINALE della linkedList
    
    sw t3, 0(t4)          # aggiornamento PBACK del nodo SUCCESSIVO rispetto a quello da rimuovere
    sw t4, 5(t3)          # aggiornamento PAHEAD del nodo PRECEDENTE rispetto a quello da rimuovere
    j elimina
DEL_testa:
    li t5, 1              # se voglio eliminare un valore , ed esso si trova in testa alla lista e la lunghezza della lista = 1 , allora ? l'unico nodo della lista 
    bne s10, t5, DEL_testa_nonUnica
    addi a5, a5, -1       # diminuisco a5 , in modo che il nuovo valore(char) possa essere inserito come il primo (da aggiungere)
    j elimina
DEL_testa_nonUnica:    
    lw t5, 5(a3)
    sw zero, 0(t5)        # per sicurezza metto tale parola uguale a ZERO
    sw s3, 0(t5)
    add s2, t5, zero      # nuovo indirizzo alla testa della linked list, dopo l'esecuzione del programma fine deve essere recuperata ;poich? ? un registro TIPO "S"
    j elimina
DEL_coda:
    lw t5, 0(a3)          # t5 contiene l'indirizzo alla TESTA del nodo precedente rispetto a quello da rimuovere
    sw zero, 5(t5)        # per sicurezza metto tele parola uguale a ZERO
    sw s3, 5(t5)
    add a2, t5, zero  # aggiornamento dell'ultimo l'indirizzo memorizzato in a2, a partire da cui viene calcolato il nuovo 16-bit-LFSR (per aggiungere un nuovo nodo)

elimina:
    sw zero, 0(a3)   # i puntatori e data vengono messi a zero, l'unico modo di eliminare un nodo
    sb zero, 4(a3)
    sw zero, 5(a3)
    addi s10, s10, -1  # diminuiamo il valore del registro che indica la lunghezza della lista concatenata doppia
    j incremento_split
el_notExists:
    la a0, nonEsiste
    li a7, 4
    ecall
    j incremento_split  


###########################################################
####                    REV method                      ###
###########################################################
REV:
    add t3, zero, zero # prev = null
    add a3, s2, zero # curr = head
    add a2, s2, zero  # aggiornamento del registro a2 , in modo che i prossimi inserimenti , vengono eseguiti dal esso 

REV_loop:

    #start swap
    lw t4, 0(a3) # PBACK
    lw t5, 5(a3) # PAHEAD
    
    sw t5, 0(a3) # PBACK = PAHEAD 
    sw t4, 5(a3) # PAHEAD = new.node
    #end swap
    
    add t3, a3, zero # prev = curr
    
    lw t6, 0(a3)     #  PBACK del nodo corrente dopo REV
    add a3, t6, zero # curr = PBACK
    beq a3, s3, end_REV
    
    j REV_loop
end_REV:
    add s2, t3, zero   # head = perv
    jr ra 
 
###########################################################
####                    SORT method                     ###
###########################################################
SORT:
     add a0, s4, zero # a0 contiene l'indirizzo alla testa del ARRAY
     li a1, 0         #  contatore dell'array 
     add a4, s2, zero # a4 contiene l'indirizzo alla testa della LISTA
     li t3, 0
     
inserting_loop: # in questo loop: tutti i valori nel campo DATA della lista vengono inseriti nell'array (per ordinare dopo nel sorting_loop)
   
    lb t4, 4(a4)      # t4 contiene il char della lista_concatenata_doppia

    add t3, a1, a0    
    sb t4, 0(t3)      # il char viene memorizzato nell'array
    addi a1, a1, 1    # incrementa array counter
    
    lw t5, 5(a4)      # memorizzo l'indirizzo alla testa del prossimo nodo in t5
    beq t5, s3, sorting_loop # se indica la fine della lista ? 0xFFFFFFFF, va a sorting_loop
    add a4, t5, zero         # altrimenti andiamo a aggiungere prossimo char nell'array 
    j inserting_loop
    
sorting_loop:
    jal ordina
  
    li a7, 126      #a7 contiene ascii di ~
    add s6, s2, zero    # s6 contiene l'indirizzo alla testa della linkedList
    add a0, s4, zero    # a0 contiene l'indirizzo alla testa dell?array gi? ORDINATO

    #ADD_maiuscole
    li t3, 0
    li a3, 65
    li a4, 90
    jal ADDtoList_inOrdine
   
    #ADD_minuscole
    li t3, 0
    li a3, 97
    li a4, 122
    jal ADDtoList_inOrdine
  
    #ADD_numeri
    li t3, 0
    li a3, 48
    li a4, 57
    jal ADDtoList_inOrdine
   
   #ADD_caratteri_extra
    li t3, 0
    j cerca_char

ADDtoList_inOrdine:
    bgt t3, s10, end_adding # se i > n allora non ci sono di piu i caratteri del tipo attuale
    
    add t4, t3, a0
    lb t5, 0(t4)
    
    blt t5, a3, incremento_M
    bgt t5, a4, incremento_M
    sb a7, 0(t4) # se ? un valore corretto , dopo la memorizzazione in t5 , viene messo uguale a ~ , torna utile per trovare caratteri EXTRA "cerca_char"
       
    sb t5, 4(s6)
    lw a6, 5(s6)
    beq a6, s3, end_sorting # se a6 = 0xFFFFFFFF allora vai a end_sorting (la lista risulta ordinata in ordine decrescente)
    add s6, a6, zero
incremento_M:
    addi t3, t3, 1
    j ADDtoList_inOrdine
end_adding:
    jr ra


cerca_char: 
    bgt t3, s10, end_sorting # se i > n allora vai a end_sorting (la lista risulta ordinata in ordine decrescente)
    
    add t4, t3, a0
    lb t5, 0(t4)
    
    beq t5, a7, incremento_indice # se un valore ? != ~ allora certamente ? un "carattere extra"
    
    sb t5, 4(s6)            # t5 contiene la data
    lw a6, 5(s6)            # a6 contiene PAHEAD del nodo corrente
    beq a6, s3, end_sorting # se a6 = 0xFFFFFFFF allora vai a end_sorting (la lista risulta ordinata in ordine decrescente)
    add s6, a6, zero
incremento_indice:
    addi t3, t3, 1
    j cerca_char  
     
end_sorting:
    jal REV  # per restituire la LISTA_CONCATENATA_DOPPIA in ordine CRESCENTE
    j incremento_split      
    
    
########################### BUBLE_SORT ###########################    
ordina:
    addi sp, sp, -20
    sw ra, 16(sp)   # salva l'indirizzo di ritorno in stack
    sw t6, 12(sp) 
    sw t5, 8(sp)
    sw t4, 4(sp)    # salva j nello stack
    sw t3, 0(sp)    # salva i nello stack
    
    mv t5, a0   # salva a0 in s5 , in modo di poter essere utilizzato dal scambia
    mv t6, a1   # salva a1 in s6 , in modo di poter essere utilizzato dal scambia
    li t3, 0    # contatore i = 0
    
for1tst:
    bge t3, t6, esci1    # se i >= n vai a esci1
    addi t4, t3, -1      # j = i - 1
for2tst:
   
    #PRIMA condizione
    blt t4,zero, esci2   # se j < 0 vai a esci2
    
    #SECONDA condizione
    add a3, t5, t4       # a3 = arrayaddress + (j)
    
    lb a4, 0(a3)         # a4 = arr[i]
    lb a6, 1(a3)         # a6 = arr[i+1]
    
    ble a6, a4, esci2    # se arr[i+1] < arr[i] vai a esci2 _ SECONDA condizione, voglio ordine DECRESCENTE
   
    # mamorizzazione ; in modo da rendere disponibile per la procedura scambia
    mv a0, t5            # i parametri v , j vengono memorizzati in a0, a1
    mv a1, t4            #  per poter essere utilizzati (passati) a scambia
    
    jal scambia          # chiama scambia
    
    #Decremento
    addi t4, t4, -1      # j--
    j for2tst
    
esci2:
    addi t3, t3, 1        # i++
    j for1tst
    
esci1:
    lw t3, 0(sp)          # ripristino dei valori dallo stack
    lw t4, 4(sp)
    lw t5, 8(sp)
    lw t6, 12(sp)
    lw ra, 16(sp)
    addi sp, sp, 20       # ripristino dello stack
    
    jr ra


scambia:
    add a6, a1, a0        # a6 = arrayaddress + (j)
    
    lb a3, 0(a6)          # a3 = v[k]
    lb a4, 1(a6)          # a4 = v[k+1]
    
    sb a4, 0(a6)          # v[k] = il valore in t1
    sb a3, 1(a6)          # v[k+1] = il valore in t0
    
    jr ra
  


     
###########################################################
####                   PRINT method                     ###
###########################################################
PRINT:
    beq s10,zero, empty_Linked_List
    add a4, s2, zero
start_print:
    la a0, newline    # stampa una nuova riga
    li a7, 4
    ecall
        
    la a0, line    # stampa " | "
    li a7, 4
    ecall
    
    lw a0, 0(a4)    # stampa l'indirizzo contenuto in PBACK in HEX
    li a7, 34
    ecall
    
    la a0, line    # stampa " | "
    li a7, 4
    ecall
    
    lb a0, 4(a4)    # stampa la data contenuto nel campo DATA
    li a7, 11
    ecall
        
    la a0, line
    li a7, 4
    ecall
    
    lw t3, 5(a4)    # stampa l'indirizzo contenuto in PAHEAD
    add a0, t3, zero
    li a7, 34
    ecall
            
    la a0, line
    li a7, 4
    ecall

    add a4, t3, zero
    beq a4, s3, incremento_split # incrememento_split , se arriva alla fine della lista, allora: non ci sar? neiente altro da stampare
    j start_print

empty_Linked_List:    # indica che la lista al momento ? vuota
    la a0, empty_linkedList
    li a7, 4
    ecall
    j incremento_split 
  

###########################################################
####                       END                          ###
###########################################################  
end_func:
    li s2, 0x00002000
    la a0, fine
    li a7, 4
    ecall
    