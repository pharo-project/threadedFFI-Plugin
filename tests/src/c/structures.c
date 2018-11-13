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
