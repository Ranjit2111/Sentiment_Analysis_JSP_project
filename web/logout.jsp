<%@ page session="true" %>
<%
    // Invalidate the session to log out the user
    session.invalidate();

    // Redirect to the sign-in page
    response.sendRedirect("signin.jsp");
%>
