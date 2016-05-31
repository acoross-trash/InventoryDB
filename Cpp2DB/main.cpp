#include <exception>
#include <iostream>

#include <Windows.h>
#include <sql.h>
#include <sqlext.h>

class MyDBCon
{
public:
	void Connect()
	{
		SQLHENV henv;
		SQLHDBC hdbc;
		SQLHSTMT hstmt;
		SQLRETURN retcode;

		SQLCHAR * OutConnStr = (SQLCHAR *)malloc(255);
		SQLSMALLINT * OutConnStrLen = (SQLSMALLINT *)malloc(255);

		// Allocate environment handle
		retcode = SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &henv);

		// Set the ODBC version environment attribute
		if (retcode == SQL_SUCCESS || retcode == SQL_SUCCESS_WITH_INFO)
		{
			retcode = SQLSetEnvAttr(henv, SQL_ATTR_ODBC_VERSION, (void*)SQL_OV_ODBC3, 0);

			// Allocate connection handle
			if (retcode == SQL_SUCCESS || retcode == SQL_SUCCESS_WITH_INFO)
			{
				retcode = SQLAllocHandle(SQL_HANDLE_DBC, henv, &hdbc);

				// Set login timeout to 5 seconds
				if (retcode == SQL_SUCCESS || retcode == SQL_SUCCESS_WITH_INFO)
				{
					SQLSetConnectAttr(hdbc, SQL_LOGIN_TIMEOUT, (SQLPOINTER)5, 0);

					// Connect to data source
					retcode = SQLDriverConnect(hdbc,
						NULL, //GetDesktopWindow(),
						(SQLCHAR*)"driver={SQL Server};Server=localhost\\SQLEXPRESS;Database=InventoryDB;Uid=test;Pwd=aaaa1111;Trusted_Connection=Yes",
						SQL_NTS,
						NULL,
						0,
						NULL,
						SQL_DRIVER_NOPROMPT);

					// Allocate statement handle
					if (retcode == SQL_SUCCESS || retcode == SQL_SUCCESS_WITH_INFO)
					{
						retcode = SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);

						// Process data
						if (retcode == SQL_SUCCESS || retcode == SQL_SUCCESS_WITH_INFO)
						{
							SQLFreeHandle(SQL_HANDLE_STMT, hstmt);
						}
						SQLDisconnect(hdbc);
					}
					else if (retcode == SQL_ERROR)
					{
						ShowErrorReason(retcode, hdbc);
					}

					SQLFreeHandle(SQL_HANDLE_DBC, hdbc);
				}
			}
			SQLFreeHandle(SQL_HANDLE_ENV, henv);
		}
	}

private:
	void ShowErrorReason(SQLRETURN ret, SQLHDBC hDbc)
	{
		if (ret == SQL_ERROR)
		{
			SQLSMALLINT iRec = 0;
			SQLINTEGER  iError;
			SQLCHAR       szMessage[1000];
			SQLCHAR       szState[SQL_SQLSTATE_SIZE + 1];
			while (SQLGetDiagRec(SQL_HANDLE_DBC,
				hDbc,
				++iRec,
				szState,
				&iError,
				szMessage,
				(SQLSMALLINT)(sizeof(szMessage) / sizeof(WCHAR)),
				(SQLSMALLINT *)NULL) == SQL_SUCCESS)
			{
				std::cout << szState << ", " << szMessage << " (" << iError << ")" << std::endl;
			}
		}
	}
};

int main()
{
	try{
		MyDBCon con;
		con.Connect();
	}
	catch (std::exception& ex)
	{
		std::cout << ex.what() << std::endl;
	}

	system("pause");

	return 0;
}