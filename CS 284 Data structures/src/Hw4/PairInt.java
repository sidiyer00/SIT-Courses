package Hw4;

public class PairInt {
    private int x;
    private int y;

    public PairInt(int x, int y){
        this.x = x;
        this.y = y;
    }

    public int getX(){
        return x;
    }

    public int getY(){
        return y;
    }

    public void setX(int num){
        x = num;
    }

    public void setY(int num){
        y = num;
    }

    public boolean equals(Object pair){
        return (this.x == ((PairInt) pair).getX() && this.y == ((PairInt) pair).getY());
    }

    public PairInt copy(){
        return new PairInt(this.x, this.y);
    }

    public String toString(){
        return "(" + x + ", " + y + ")";
    }
}
