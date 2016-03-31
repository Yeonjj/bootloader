#include <fstream>
#include <iostream>

using namespace std;

int main(int argc, char *argv[]) 
{
	if(argc >= 4){
	    	ifstream ifile(argv[1], ios::in);  //입력 (가져옴)
		ifstream ifile_(argv[2], ios::in);
		ofstream ofile(argv[3], ios::out | ios::app); //출력 , 덫붙
	
		try {
			if (!(ifile.is_open() && ifile_.is_open())) {
				cout << "file not open" << endl;
			}
			else {
		    		ofile << ifile.rdbuf();
				ofile << ifile_.rdbuf();
			}      
		}catch(exception e){
			cout << "error: " <<endl;
		}
	}else{cout << "insufficient input" << endl; }

	return 0;

}

 
