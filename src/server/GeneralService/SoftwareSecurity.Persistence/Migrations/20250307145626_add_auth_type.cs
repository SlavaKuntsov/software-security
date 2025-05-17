using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SoftwareSecurity.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class add_auth_type : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: "01JMZ1NB7AG0WZSB5ZAJFWT2ST");

            migrationBuilder.AddColumn<string>(
                name: "AuthType",
                table: "Users",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "AuthType", "DateOfBirth", "Email", "FirstName", "LastName", "Password", "Role" },
                values: new object[] { "01JNRHQ3CP4RJBVFD11XVRVQJV", "Login", "", "admin@email.com", "admin", "admin", "$2a$11$5CPNAx4Oj8BvZtDgo5pbB.ho/wOZKGTEGah1UH4WRR6zc0lFgTpIi", "Admin" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Users",
                keyColumn: "Id",
                keyValue: "01JNRHQ3CP4RJBVFD11XVRVQJV");

            migrationBuilder.DropColumn(
                name: "AuthType",
                table: "Users");

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "DateOfBirth", "Email", "FirstName", "LastName", "Password", "Role" },
                values: new object[] { "01JMZ1NB7AG0WZSB5ZAJFWT2ST", "", "admin@email.com", "admin", "admin", "$2a$11$iMhpdHwkuH8acEUZfapOueUHduMccYsN79RFhRvT8MHtoDb6iwl3G", "Admin" });
        }
    }
}
