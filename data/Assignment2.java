import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
//import java.util.ArrayList;
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
        return false;
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
        return false;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        // Implement this method!
        return null;
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
        // 
        List<Integer> similarPolitician = new List<Integer>;

        PreparedStatement politician_info = conn.prepareStatement(
            "SELECT id, description, comment FROM politician_president WHERE id =" + String.valueOf(politicianName)); 
            ResultSet pol_data = politician_info.executeQuery();  
        pol_data.next();  
        String pol_description = pol_data.getString("description");
        String pol_comment = pol_data.getString("comment");

        PreparedStatement compare = conn.prepareStatement(
        “
        SELECT id, description, comment FROM politician_president
        ”);

        ResultSet data = compare.executeQuery();
        while (data.next()) {
        int id = data.getInt(id);
        String description = data.getString("description");
        String comment = data.getString("comment");
        If(similarity(pol_comment + " " + pol_comment, description + " " + comment) > threshold){
            similarPolitician.add(id);  
        }
        return similarPolitician;
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");
    }

}

