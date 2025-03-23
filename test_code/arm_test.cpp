#include <iostream>
#include <vector>
#include <string>

using namespace std;

int subtract(int a, int b)
{
    return a - b;
}

int main()
{
    const char *languages_array[] = {"C++", "Python", "Java"};
    vector<string> languages(languages_array, languages_array + sizeof(languages_array) / sizeof(languages_array[0]));

    for (vector<string>::const_iterator it = languages.begin(); it != languages.end(); ++it)
    {
        cout << *it << endl;
    }

    cout << "10 - 7 = " << subtract(10, 7) << endl;
    return 0;
}
