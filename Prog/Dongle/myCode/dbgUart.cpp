#include "string.h"
#include "stdarg.h"


#include "main.h"
#include "dbgUart.h"

#define UART_NR  2

#if (UART_NR == 1)

#define UART_DEV    USART1
#define UART_IRQn   USART1_IRQn
#define U_TX_Pin GPIO_PIN_9
#define U_RX_Pin GPIO_PIN_10


#elif (UART_NR == 2)

#define UART_DEV    USART2
#define UART_IRQn   USART2_IRQn
#define U_TX_Pin GPIO_PIN_2
#define U_RX_Pin GPIO_PIN_3

#elif (UART_NR == 3)

#define UART_DEV    USART3
#define UART_IRQn   USART3_IRQn
#define U_TX_Pin 	GPIO_PIN_8
#define U_RX_Pin 	GPIO_PIN_9
#define UART_GPIO 	GPIOD

#endif

#define UART_PRIORITY 2

DbgCnt DbgUart::cntRec;
DbgRxData DbgUart::rxData;
DbgTxData DbgUart::txData;

void DbgUart::IrqRXChar(uint8_t a) {

	uint16_t n = rxData.head;
	if (++n == DBG_RX_BUF_SIZE)
		n = 0;
	if (n != rxData.tail) {
		rxData.buf[rxData.head] = a;
		rxData.head = n;
	} else {
		cntRec.RxLost++;
	}
	cntRec.Rx++;
}

void DbgUart::Senduint8_tHd(uint8_t a) {
	UART_DEV->DR = a;
	cntRec.Tx++;
}

uint8_t DbgUart::PopTxData() {
	uint8_t a = txData.buf[txData.tail];
	if (++txData.tail == DBG_TX_BUF_SIZE)
		txData.tail = 0;
	return a;
}

void DbgUart::IrqTXChar() {
	if (txData.tail != txData.head) {
		Senduint8_tHd(PopTxData());
	} else {
		UART_DEV->CR1 &= ~USART_CR1_TXEIE; // zablkowanie przerwa� od pustego bufora nadajnika
		txData.sending = false;
	}
}

void DbgUart::StartSend(void) {
	if (!txData.sending) {
		if (!txData.complete)
			UART_DEV->CR1 |= USART_CR1_TXEIE;
		else {
			Senduint8_tHd(PopTxData());
			UART_DEV->CR1 |= (USART_CR1_TXEIE | USART_CR1_TCIE); // wys�anego znaku i ko�ca transmisji
			txData.complete = false;
		}
		txData.sending = true;
	}
}

void DbgUart::IRQ(void) {

	cntRec.Irq++;
	__IO uint32_t tmpreg = 0x00U;
// frame error, Noise error or data recived interrupt

	if (UART_DEV->SR & (UART_FLAG_RXNE | UART_FLAG_FE | UART_FLAG_NE)) {
		bool dtOK = true;
		if (UART_DEV->SR & UART_FLAG_FE) {
			//framing Error
			tmpreg = UART_DEV->SR;
			tmpreg = UART_DEV->DR;
			dtOK = false;
		} else if (UART_DEV->SR & UART_FLAG_NE) {
			//Noise detection error
			tmpreg = UART_DEV->SR;
			tmpreg = UART_DEV->DR;
			dtOK = false;
		} else if (UART_DEV->SR & UART_FLAG_ORE) {
			//Overrun error
			tmpreg = UART_DEV->SR;
			tmpreg = UART_DEV->DR;
			dtOK = false;
		} else if (UART_DEV->SR & UART_FLAG_PE) {
			//Parrity error
			tmpreg = UART_DEV->SR;
			tmpreg = UART_DEV->DR;
			dtOK = false;
		}
		uint8_t a = UART_DEV->DR;
		if (dtOK) {
			IrqRXChar(a);
		}

	}

	//przerwanie od putego rejestru nadajnika
	if (UART_DEV->SR & UART_FLAG_TXE) {
		IrqTXChar();
	}

	//przerwanie od ko�ca nadawania ostatniego znaku
	if (UART_DEV->SR & UART_FLAG_TC) {
		tmpreg = UART_DEV->SR;
		tmpreg = UART_DEV->DR;
		UART_DEV->CR1 &= ~USART_CR1_TCIE; // wy��czeie przerwania od ko�ca
		txData.complete = true;
	}

// UART parity error interrupt occurred
	if (UART_DEV->SR & UART_FLAG_PE) {
		UART_DEV->CR1 &= ~USART_CR1_PEIE;
	}
	UNUSED(tmpreg);

}

void DbgUart::Init(uint32_t baudRate) {
	txData.sending = false;
	txData.complete = true;

	UART_HandleTypeDef huart;
	memset(&huart, 0, sizeof(huart));

	huart.Instance = UART_DEV;
	huart.Init.BaudRate = baudRate;
	huart.Init.WordLength = UART_WORDLENGTH_8B;
	huart.Init.StopBits = UART_STOPBITS_1;
	huart.Init.Parity = UART_PARITY_NONE;
	huart.Init.Mode = UART_MODE_TX_RX;
	huart.Init.HwFlowCtl = UART_HWCONTROL_NONE;
	huart.Init.OverSampling = UART_OVERSAMPLING_16;
	if (HAL_UART_Init(&huart) != HAL_OK) {

		SET_BIT(huart.Instance->CR1, USART_CR1_RE); //enable reciver
		SET_BIT(huart.Instance->CR1, USART_CR1_TE); //enable transmiter
		SET_BIT(huart.Instance->CR1, USART_CR1_UE); //enable UART
		SET_BIT(huart.Instance->CR1, USART_CR1_RXNEIE); // za�aczone przerwania od odbiornika;

		HAL_NVIC_SetPriority(UART_IRQn, UART_PRIORITY, 0);
		HAL_NVIC_EnableIRQ(UART_IRQn);
	}

}

bool DbgUart::Write(const char *buf, int len) {
	int free = (int) txData.tail - txData.head;
	if (free <= 0)
		free += DBG_TX_BUF_SIZE;
	if (len > free - 1)
		return false;

	int n = DBG_TX_BUF_SIZE - txData.head;
	if (n > len)
		n = len;

	memcpy(&txData.buf[txData.head], buf, n);

	txData.head += n;
	if (txData.head >= DBG_TX_BUF_SIZE)
		txData.head = 0;

	len -= n;
	if (len > 0) {
		memcpy(txData.buf, &buf[n], len);
		txData.head = len;
	}

	StartSend();

	return true;
}

bool DbgUart::WriteStr(const char *buf) {
	return Write(buf, strlen(buf));
}

void DbgUart::WriteClear() {
	if (txData.sending) {
		txData.sending = false;
	}
	txData.tail = 0;
	txData.head = 0;
}

bool DbgUart::GetRxChar(char *ch) {
	if (rxData.head == rxData.tail)
		return false;
	*ch = rxData.buf[rxData.tail];
	if (++rxData.tail == DBG_RX_BUF_SIZE)
		rxData.tail = 0;
	return true;
}

void DbgUart::ReadClear() {
	rxData.tail = 0;
	rxData.head = 0;
}

bool DbgUart::GetKey(char *key) {
	if (rxData.head == rxData.tail)
		return false;

	*key = rxData.buf[rxData.tail];
	if (++rxData.tail == DBG_RX_BUF_SIZE) {
		rxData.tail = 0;
	}
	return true;
}

extern "C" void DbgUart_IRQ(void){
	DbgUart::IRQ();
}
