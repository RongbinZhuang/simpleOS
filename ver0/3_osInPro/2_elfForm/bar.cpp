extern "C" 
{
	void myprint(char* msg,int len);
	int choose(int a,int b);
};
int	choose(int a,int b)
{
	if(a>=b)
	{
		myprint((char *)"the 1st one\n",13);
	}
	else
	{
		myprint((char *)"the 2nd one\n",13);
	}
	return 0;
}
