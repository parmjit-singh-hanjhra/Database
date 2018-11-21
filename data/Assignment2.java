import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {
    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
        try { // Connection successful
          connection = DriverManager.getConnection ( url,
          username, password);
          return true;
        } catch(SQLException se){ //Connection Error
             System.err.println("SQL Exception." +
                     "<Message>: " + se.getMessage());
          return false;
        }
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
        try { // Connection successful
          connection.close();
          return true;
        } catch(SQLException se){ //Connection Error
          System.err.println("SQL Exception." +
                  "<Message>: " + se.getMessage());
          return false;
        }
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        // Implement this method!
        List<Integer> elections = new ArrayList<Integer>();
        List<Integer> cabinets = new ArrayList<Integer>();
        try{
        String queryString = " SELECT election.id AS eID, election.e_date AS eDate, cabinet.id AS cID " +
                              "FROM ((parlgov.country country JOIN parlgov.election election ON (country.id = election.country_id)) " +
                              "LEFT JOIN parlgov.cabinet cabinet ON (election.id = cabinet.election_id)) " +
                              "WHERE country.name = '" + countryName + "'" + 
                              " ORDER BY eDate DESC";
        PreparedStatement ps = connection.prepareStatement(queryString);

        ResultSet rs = ps.executeQuery();

        while(rs.next()){
          int electionID = rs.getInt("eID");
          int cabinetID = rs.getInt("cID");
          elections.add(electionID);
          if (cabinetID != 0){
            cabinets.add(cabinetID);
          }
        }

      }catch(SQLException se){
        System.err.println("SQL Exception." +
                "<Message>: " + se.getMessage());
      }
      return new ElectionCabinetResult(elections, cabinets);

    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
        // Implement this method!
        //
        List<Integer> similarPolitician = new ArrayList<Integer>();
        try{

        PreparedStatement politician_info = connection.prepareStatement(
            "SELECT id, description, comment FROM parlgov.politician_president politician_president WHERE id =" + String.valueOf(politicianName));
            ResultSet pol_data = politician_info.executeQuery();
        pol_data.next();
        String pol_description = pol_data.getString("description");
        String pol_comment = pol_data.getString("comment");

        PreparedStatement compare = connection.prepareStatement(
        "SELECT id, description, comment FROM parlgov.politician_president politician_president " +
        "WHERE id <> " + String.valueOf(politicianName));

        ResultSet data = compare.executeQuery();
        while (data.next()) {
          int id = data.getInt("id");
          String description = data.getString("description");
          String comment = data.getString("comment");
          if(similarity(pol_description + " " + pol_comment, description + " " + comment) > threshold){
              similarPolitician.add(id);
          }
        }
      }catch(SQLException se){
        System.err.println("SQL Exception." +
                "<Message>: " + se.getMessage());
      }
      return similarPolitician;

    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        try{
          Assignment2 a = new Assignment2();
          System.out.println("Hello");
          a.connectDB("jdbc:postgresql://localhost:5432/csc343h-mortages", "mortages", "");
          ElectionCabinetResult esTest = a.electionSequence("Canada");
          System.out.println(esTest);
          List<Integer> fspTest = a.findSimilarPoliticians(148,(float) 0.25);
          System.out.println(fspTest);
          a.disconnectDB();
        }catch(ClassNotFoundException e){
          System.out.println("Class not found");
        }

    }

}

