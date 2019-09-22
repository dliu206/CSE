import java.io.FileInputStream;
import java.sql.*;
import java.util.PriorityQueue;
import java.util.Properties;

public class -OMITTED-
{
    public class Itineraries implements Comparable{
        public Flight f1;
        public Flight f2;
        public int time;
        public int day;

        public Itineraries(Flight f1, Flight f2, int time, int day) {
            this.f1 = f1;
            this.f2 = f2;
            this.time = time;
            this.day = day;
        }

        @Override
        public int compareTo(Object o) {
            Itineraries temp = (Itineraries) o;
            if (this.time < temp.time) {
                return -1;
            } else if (this.time == temp.time) {
                if (this.f1.fid < temp.f1.fid) {
                    return -1;
                } else {
                    return 1;
                }
            } else {
                return 1;
            }
        }
    }

    private PriorityQueue<Itineraries> pq;


    private String configFilename;


    protected Connection conn;

    private static final String BEGIN_TRANSACTION_SQL = "SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; BEGIN TRANSACTION;";
    protected PreparedStatement beginTransactionStatement;

    private static final String COMMIT_SQL = "COMMIT TRANSACTION";
    protected PreparedStatement commitTransactionStatement;

    private static final String ROLLBACK_SQL = "ROLLBACK TRANSACTION";
    protected PreparedStatement rollbackTransactionStatement;


    private static final String CHECK_FLIGHT_CAPACITY = "SELECT capacity FROM Flights WHERE fid = ?";
    protected PreparedStatement checkFlightCapacityStatement;

    private static final String FLIGHT_QUERY_DIRECT =
            "SELECT TOP (?) fid,day_of_month,carrier_id,flight_num,origin_city,dest_city,actual_time,capacity,price "
                    + "FROM Flights "
                    + "WHERE origin_city = ? " +
                    "AND dest_city = ? " +
                    "AND day_of_month = ? AND canceled = 0"
                    + "ORDER BY actual_time,fid ASC";

    protected PreparedStatement flightStatementDirect;

    private static final String FLIGHT_QUERY_INDIRECT =
            "SELECT TOP(?) X.fid AS fid1,X.day_of_month AS day1,X.carrier_id AS carrier1,X.flight_num AS fnum1,X.origin_city AS origin1,X.dest_city AS dest1,X.actual_time AS time1,\n" +
                    "X.capacity AS capacity1,X.price AS price1, \n" +
                    "Y.fid AS fid2,Y.day_of_month AS day2,Y.carrier_id AS carrier2,Y.flight_num AS fnum2,Y.origin_city AS origin2,Y.dest_city AS dest2,Y.actual_time as time2,\n" +
                    "Y.capacity AS capacity2,Y.price AS price2, X.actual_time + Y.actual_time AS time3\n" +
                    "FROM FLIGHTS X, FLIGHTS Y\n" +
                    "WHERE X.origin_city = ? AND X.dest_city = Y.origin_city\n" +
                    "AND Y.dest_city = ? AND Y.day_of_month = ?\n" +
                    "AND X.day_of_month = Y.day_of_month\n" +
                    "AND NOT X.dest_city = ?\n AND X.canceled = 0 AND Y.canceled = 0 " +
                    "ORDER BY time3, X.fid, Y.fid ASC";
    protected PreparedStatement flightStatementIndirect;

    private static final String INSERT_ITINERARY = "INSERT INTO ITINERARIES VALUES(?, ?, ?, ?)";
    protected PreparedStatement insertItineraryStatement;

    private static final String CLEAR_ITINERARY = "DELETE FROM ITINERARIES";
    protected PreparedStatement clearItineraryStatement;

    private int direct;
    protected int itineraryIndex;

    class Flight
    {
        public int fid;
        public int dayOfMonth;
        public String carrierId;
        public String flightNum;
        public String originCity;
        public String destCity;
        public int time;
        public int capacity;
        public int price;

        @Override
        public String toString()
        {
            return "ID: " + fid + " Day: " + dayOfMonth + " Carrier: " + carrierId +
                    " Number: " + flightNum + " Origin: " + originCity + " Dest: " + destCity + " Duration: " + time +
                    " Capacity: " + capacity + " Price: " + price;
        }
    }

    public QuerySearchOnly(String configFilename)
    {
        this.configFilename = configFilename;
    }

    /** Open a connection to SQL Server in Microsoft Azure.  */
    public void openConnection() throws Exception
    {
        Properties configProps = new Properties();
        configProps.load(new FileInputStream(configFilename));

        String jSQLDriver = configProps.getProperty("flightservice.jdbc_driver");
        String jSQLUrl = configProps.getProperty("flightservice.url");
        String jSQLUser = configProps.getProperty("flightservice.sqlazure_username");
        String jSQLPassword = configProps.getProperty("flightservice.sqlazure_password");

    /* load jdbc drivers */
        Class.forName(jSQLDriver).newInstance();

    /* open connections to the flights database */
        conn = DriverManager.getConnection(jSQLUrl, // database
                jSQLUser, // user
                jSQLPassword); // password

        conn.setAutoCommit(true); //by default automatically commit after each statement
    /* In the full Query class, you will also want to appropriately set the transaction's isolation level:
          conn.setTransactionIsolation(...)
       See Connection class's JavaDoc for details.
    */
        conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
    }


    public void closeConnection() throws Exception
    {
        conn.close();
    }

    /**
     * prepare all the SQL statements in this method.
     * "preparing" a statement is almost like compiling it.
     * Note that the parameters (with ?) are still not filled in
     */
    public void prepareStatements() throws Exception
    {
        beginTransactionStatement = conn.prepareStatement(BEGIN_TRANSACTION_SQL);
        commitTransactionStatement = conn.prepareStatement(COMMIT_SQL);
        rollbackTransactionStatement = conn.prepareStatement(ROLLBACK_SQL);

        checkFlightCapacityStatement = conn.prepareStatement(CHECK_FLIGHT_CAPACITY);

        flightStatementDirect = conn.prepareStatement(FLIGHT_QUERY_DIRECT);

        flightStatementIndirect = conn.prepareStatement(FLIGHT_QUERY_INDIRECT);

        insertItineraryStatement = conn.prepareStatement(INSERT_ITINERARY);

        clearItineraryStatement = conn.prepareStatement(CLEAR_ITINERARY);
    }


    /**
     * Implement the search function.
     *
     * Searches for flights from the given origin city to the given destination
     * city, on the given day of the month. If {@code directFlight} is true, it only
     * searches for direct flights, otherwise it searches for direct flights
     * and flights with two "hops." Only searches for up to the number of
     * itineraries given by {@code numberOfItineraries}.
     *
     * The results are sorted based on total flight time.
     *
     * @param originCity
     * @param destinationCity
     * @param directFlight if true, then only search for direct flights, otherwise include indirect flights as well
     * @param dayOfMonth
     * @param numberOfItineraries number of itineraries to return
     *
     * @return If no itineraries were found, return "No flights match your selection\n".
     * If an error occurs, then return "Failed to search\n".
     *
     * Otherwise, the sorted itineraries printed in the following format:
     *
     * Itinerary [itinerary number]: [number of flights] flight(s), [total flight time] minutes\n
     * [first flight in itinerary]\n
     * ...
     * [last flight in itinerary]\n
     *
     * Each flight should be printed using the same format as in the {@code Flight} class. Itinerary numbers
     * in each search should always start from 0 and increase by 1.
     *
     * @see Flight#toString()
     */
    public String transaction_search(String originCity, String destinationCity, boolean directFlight, int dayOfMonth,
                                     int numberOfItineraries)
    {
        String result;
        itineraryIndex = 0;
        if (directFlight) {
            try {
                beginTransaction();
                clearItineraryStatement.executeUpdate();
                result = searchDirectQuery(originCity, destinationCity, dayOfMonth, numberOfItineraries);
                commitTransaction();
            } catch (SQLException e){
                e.printStackTrace();
                return "Failed to search\n";
            }
            if (result.length() == 0) {
                return "No flights match your selection\n";
            } else {
                return result;
            }
        } else {
            try {
                beginTransaction();
                clearItineraryStatement.executeUpdate();
                searchIndirectQuery(originCity, destinationCity, dayOfMonth, numberOfItineraries);
                result = searchIndirectSort();
                commitTransaction();
            } catch (SQLException e) {
                e.printStackTrace();
                return "Failed to search\n";
            }
            if (result.length() == 0) {
                return "No flights match your selection\n";
            } else {
                return result;
            }
        }
    }

    /**
     * Same as {@code transaction_search} except that it only performs single hop search and
     * do it in an unsafe manner.
     *
     * @param originCity
     * @param destinationCity
     * @param directFlight
     * @param dayOfMonth
     * @param numberOfItineraries
     *
     * @return The search results. Note that this implementation *does not conform* to the format required by
     * {@code transaction_search}.
     */
    private String transaction_search_unsafe(String originCity, String destinationCity, boolean directFlight,
                                             int dayOfMonth, int numberOfItineraries)
    {
        StringBuffer sb = new StringBuffer();

        try
        {
            // one hop itineraries
            String unsafeSearchSQL =
                    "SELECT TOP (" + numberOfItineraries + ") day_of_month,carrier_id,flight_num,origin_city,dest_city,actual_time,capacity,price "
                            + "FROM Flights "
                            + "WHERE origin_city = \'" + originCity + "\' AND dest_city = \'" + destinationCity + "\' AND day_of_month =  " + dayOfMonth + " "
                            + "ORDER BY actual_time ASC";

            Statement searchStatement = conn.createStatement();
            ResultSet oneHopResults = searchStatement.executeQuery(unsafeSearchSQL);

            while (oneHopResults.next())
            {
                int result_dayOfMonth = oneHopResults.getInt("day_of_month");
                String result_carrierId = oneHopResults.getString("carrier_id");
                String result_flightNum = oneHopResults.getString("flight_num");
                String result_originCity = oneHopResults.getString("origin_city");
                String result_destCity = oneHopResults.getString("dest_city");
                int result_time = oneHopResults.getInt("actual_time");
                int result_capacity = oneHopResults.getInt("capacity");
                int result_price = oneHopResults.getInt("price");

                sb.append("Day: ").append(result_dayOfMonth)
                        .append(" Carrier: ").append(result_carrierId)
                        .append(" Number: ").append(result_flightNum)
                        .append(" Origin: ").append(result_originCity)
                        .append(" Destination: ").append(result_destCity)
                        .append(" Duration: ").append(result_time)
                        .append(" Capacity: ").append(result_capacity)
                        .append(" Price: ").append(result_price)
                        .append('\n');
            }
            oneHopResults.close();
        } catch (SQLException e) { e.printStackTrace(); }

        return sb.toString();
    }

    /**
     * Shows an example of using PreparedStatements after setting arguments.
     * You don't need to use this method if you don't want to.
     */
    private int checkFlightCapacity(int fid) throws SQLException
    {
        checkFlightCapacityStatement.clearParameters();
        checkFlightCapacityStatement.setInt(1, fid);
        ResultSet results = checkFlightCapacityStatement.executeQuery();
        results.next();
        int capacity = results.getInt("capacity");
        results.close();

        return capacity;
    }


    private String searchDirectQuery(String originCity, String destinationCity,
                                     int dayOfMonth, int numberOfItineraries) throws SQLException {
        direct = 0;
        String result = "";

        flightStatementDirect.clearParameters();
        flightStatementDirect.setInt(1, numberOfItineraries);
        flightStatementDirect.setString(2, originCity);
        flightStatementDirect.setString(3, destinationCity);
        flightStatementDirect.setInt(4, dayOfMonth);

        ResultSet results = flightStatementDirect.executeQuery();
        while (results.next()) {

            int result_dayOfMonth = results.getInt("day_of_month");
            String result_carrierId = results.getString("carrier_id");
            int result_fid = results.getInt("fid");
            String result_originCity = results.getString("origin_city");
            String result_destCity = results.getString("dest_city");
            int result_time = results.getInt("actual_time");
            int result_capacity = results.getInt("capacity");
            int result_price = results.getInt("price");
            String result_flightNum = results.getString("flight_num");

            Flight flight = new Flight();
            flight.dayOfMonth = result_dayOfMonth;
            flight.carrierId = result_carrierId;
            flight.fid = result_fid;
            flight.flightNum = result_flightNum;
            flight.originCity = result_originCity;
            flight.destCity = result_destCity;
            flight.time = result_time;
            flight.capacity = result_capacity;
            flight.price = result_price;

            insertItineraryStatement.clearParameters();
            insertItineraryStatement.setInt(1, itineraryIndex);
            insertItineraryStatement.setInt(2, result_fid);
            insertItineraryStatement.setInt(3, -1);
            insertItineraryStatement.setInt(4, result_dayOfMonth);
            insertItineraryStatement.executeUpdate();

            result += "Itinerary " + itineraryIndex + ": 1 flight(s), " + flight.time + " minutes\n";
            result += flight.toString() + "\n";
            direct++;

            itineraryIndex++;
        }
        results.close();
        return result;
    }


    private void searchIndirectDirectQuery(String originCity, String destinationCity,
                                           int dayOfMonth, int numberOfItineraries) throws SQLException {
        pq = new PriorityQueue<Itineraries>();
        direct = 0;

        flightStatementDirect.clearParameters();
        flightStatementDirect.setInt(1, numberOfItineraries);
        flightStatementDirect.setString(2, originCity);
        flightStatementDirect.setString(3, destinationCity);
        flightStatementDirect.setInt(4, dayOfMonth);

        ResultSet results = flightStatementDirect.executeQuery();
        while (results.next()) {

            int result_dayOfMonth = results.getInt("day_of_month");
            String result_carrierId = results.getString("carrier_id");
            int result_fid = results.getInt("fid");
            String result_originCity = results.getString("origin_city");
            String result_destCity = results.getString("dest_city");
            int result_time = results.getInt("actual_time");
            int result_capacity = results.getInt("capacity");
            int result_price = results.getInt("price");
            String result_flightNum = results.getString("flight_num");

            Flight flight = new Flight();
            flight.dayOfMonth = result_dayOfMonth;
            flight.carrierId = result_carrierId;
            flight.fid = result_fid;
            flight.flightNum = result_flightNum;
            flight.originCity = result_originCity;
            flight.destCity = result_destCity;
            flight.time = result_time;
            flight.capacity = result_capacity;
            flight.price = result_price;

            direct++;
            pq.add(new Itineraries(flight, null, result_time, result_dayOfMonth));
        }
        results.close();
    }

    private void searchIndirectQuery(String originCity, String destinationCity,
                                     int dayOfMonth, int numberOfItineraries) throws SQLException {
        searchIndirectDirectQuery(originCity, destinationCity, dayOfMonth, numberOfItineraries);

        flightStatementIndirect.clearParameters();
        flightStatementIndirect.setInt(1, numberOfItineraries - direct);
        flightStatementIndirect.setString(2, originCity);
        flightStatementIndirect.setString(3, destinationCity);
        flightStatementIndirect.setInt(4, dayOfMonth);
        flightStatementIndirect.setString(5, destinationCity);

        ResultSet results = flightStatementIndirect.executeQuery();
        while (results.next()) {

            int result_dayOfMonth = results.getInt("day1");
            String result_carrierId = results.getString("carrier1");
            int result_fid = results.getInt("fid1");
            String result_originCity = results.getString("origin1");
            String result_destCity = results.getString("dest1");
            int result_time = results.getInt("time1");
            int result_capacity = results.getInt("capacity1");
            int result_price = results.getInt("price1");
            String result_flightNum = results.getString("fnum1");

            Flight flight1 = new Flight();
            flight1.dayOfMonth = result_dayOfMonth;
            flight1.carrierId = result_carrierId;
            flight1.fid = result_fid;
            flight1.flightNum = result_flightNum;
            flight1.originCity = result_originCity;
            flight1.destCity = result_destCity;
            flight1.time = result_time;
            flight1.capacity = result_capacity;
            flight1.price = result_price;

            result_dayOfMonth = results.getInt("day2");
            result_carrierId = results.getString("carrier2");
            result_fid = results.getInt("fid2");
            result_originCity = results.getString("origin2");
            result_destCity = results.getString("dest2");
            result_time = results.getInt("time2");
            result_capacity = results.getInt("capacity2");
            result_price = results.getInt("price2");
            result_flightNum = results.getString("fnum2");

            Flight flight2 = new Flight();
            flight2.dayOfMonth = result_dayOfMonth;
            flight2.carrierId = result_carrierId;
            flight2.fid = result_fid;
            flight2.flightNum = result_flightNum;
            flight2.originCity = result_originCity;
            flight2.destCity = result_destCity;
            flight2.time = result_time;
            flight2.capacity = result_capacity;
            flight2.price = result_price;

            pq.add(new Itineraries(flight1, flight2, flight1.time + flight2.time, result_dayOfMonth));

        }
        results.close();
    }

    private String searchIndirectSort() {
        try {
            String result = "";
            itineraryIndex = 0;
            while (this.pq.size() != 0) {
                Itineraries i = pq.poll();
                if (i.f2 == null) {
                    insertItineraryStatement.clearParameters();
                    insertItineraryStatement.setInt(1, itineraryIndex);
                    insertItineraryStatement.setInt(2, i.f1.fid);
                    insertItineraryStatement.setInt(3, -1);
                    insertItineraryStatement.setInt(4, i.day);
                    insertItineraryStatement.executeUpdate();
                    result += "Itinerary " + itineraryIndex + ": 1 flight(s), " + i.time + " minutes\n";
                    result += i.f1.toString() + "\n";
                } else {
                    insertItineraryStatement.clearParameters();
                    insertItineraryStatement.setInt(1, itineraryIndex);
                    insertItineraryStatement.setInt(2, i.f1.fid);
                    insertItineraryStatement.setInt(3, i.f2.fid);
                    insertItineraryStatement.setInt(4, i.day);
                    insertItineraryStatement.executeUpdate();
                    result += "Itinerary " + itineraryIndex + ": 2 flight(s), " + i.time + " minutes\n";
                    result += i.f1.toString() + "\n";
                    result += i.f2.toString() + "\n";
                }
                itineraryIndex++;

            }
            return result;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "";
    }

    public void beginTransaction() throws SQLException
    {
        conn.setAutoCommit(false);
        beginTransactionStatement.executeUpdate();
    }

    public void commitTransaction() throws SQLException
    {
        commitTransactionStatement.executeUpdate();
        conn.setAutoCommit(true);
    }

    public void rollbackTransaction() throws SQLException
    {
        rollbackTransactionStatement.executeUpdate();
        conn.setAutoCommit(true);
    }
}
