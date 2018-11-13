typedef struct{
	int x;
	int y;
} POINT;

int sizeOfPoint(){
	return sizeof(POINT);
}

POINT newPoint(int x, int y){
	POINT p;
	p.x = x;
	p.y = y;

	return p;
}

int assertCorrectPoint(POINT aPoint, int x, int y){
	return aPoint.x == x && aPoint.y == y;
}

typedef struct{
	char a[100];
	float b;
	double c;
	long d;
	int e;
	short f;
} LONG_STRUCT;

int sizeOfLongStruct(){
	return sizeof(LONG_STRUCT);
}

int passingLongStruct(LONG_STRUCT st, float b, double c, long d){
	return st.b == b && st.c == c && st.d == d;
}

int passingLongStructByRef(LONG_STRUCT* st, float b, double c, long d){
	return st && st->b == b && st->c == c && st->d == d;
}

typedef struct {
	char a;
	void* b;
} INNER;

typedef struct{
	INNER inner;
	float x;
	double y;
} NESTED_STRUCTS;

int sizeOfNestedStruct(){
	return sizeof(NESTED_STRUCTS);
}

int passingNestedStruct(NESTED_STRUCTS st, char a, double y){
	return st.inner.a == a && st.y == y;
}
