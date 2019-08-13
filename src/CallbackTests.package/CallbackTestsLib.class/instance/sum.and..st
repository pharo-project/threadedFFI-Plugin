as yet unclassified
sum: aNumber and: anotherNumber
	^ self ffiCall: #(int sumTwoNumbers(int aNumber, int anotherNumber))