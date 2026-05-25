library("dplyr")

generate.time.till.next.customer <- function(lam=1.1){ 
  
  return (rexp(1, rate = lam)/60)
  
}



generate.shopping.time <- function(mean = 0, sd = 0.5){
  
  return( rlnorm(1,mean, sd)/60)
  
}


generate.service.time <- function(rate){
  
  return (rexp(1, rate = rate)/ 60)
  
}

choose.counter <- function(n1, n2, n3, n4){
  min.value <- min(n1, n2, n3, n4)
  if (n1 == min.value){
    return (1)
  }else if (n2 == min.value){
    return (2)
  }else if (n3 == min.value){
    return (3)
  }else {
    return (4)
  }
  
}


simulate_shop <- function(){
  
  Total_customers <- 0
  
  df <- data.frame(matrix(ncol = 6, nrow = 0))
  colnames(df) <- c("Customer_id", "Arrival_time", "Shopping_finish_time", "Service_start_time", "Departure_time", "Counter")
  
  start_time <- 8
  closing_time <- 21
  
  service_time_counter_1 <- 1/2.5
  service_time_counter_2 <- 1/3
  service_time_counter_3 <- 1/3.5
  service_time_counter_4 <- 1/4
  
  t <- start_time # Time elapsed
  N <- 0  # Number of customers in the shop
  
  N_S <- 0 # Number of customers shopping
  
  customer_id = 0
  
  t_A <- t +generate.time.till.next.customer()
  t_D <- Inf
  t_S <- t_A + generate.shopping.time()
  
  shopping_customers <- c()
  shopping_finish_times <- c()
  
  customer_id_counter_1 <- c()
  service_start_times_1 <- c()
  departure_times_counter_1 <- c()
  nc1 <- 0 # Number of customers at counter 1
  t_D_1 <-Inf # Next Departure Time for counter 1
  t_C_1 <- 0
  
  customer_id_counter_2 <- c()
  service_start_times_2 <- c()
  departure_times_counter_2 <- c()
  nc2 <- 0 # Number of customers at counter 2
  t_D_2 <-Inf # Next Departure Time for counter 2
  t_C_2 <- 0
  
  customer_id_counter_3 <- c()
  service_start_times_3 <- c()
  departure_times_counter_3 <- c()
  nc3 <- 0 # Number of customers at counter 3
  t_D_3 <-Inf # Next Departure Time for counter 3
  t_C_3 <- 0
  
  customer_id_counter_4 <- c()
  service_start_times_4 <- c()
  departure_times_counter_4 <- c()
  nc4 <- 0 # Number of customers at counter 4
  t_D_4 <-Inf # Next Departure Time for counter 4
  t_C_4 <- 0
  
  
  
  
  while(!(t >= closing_time && N == 0) ){
   
    
    if (t_A > closing_time){
      t_A <- Inf
    }
    
    if (N == 0){
      t_D <- Inf
    }else{
      
      if (nc1 == 0){
        t_D_1 <- Inf
      }
      if (nc2 == 0){
        t_D_2 <- Inf
      }
      if (nc3 == 0){
        t_D_3 <- Inf
      }
      if (nc4 == 0){
        t_D_4 <- Inf
      }
      
      t_D <- min(t_D_1, t_D_2, t_D_3, t_D_4)
    }
    
    if (N_S == 0){
      t_S <- Inf
    } 
    
    
    if (t_A <= min(t_A, t_S, t_D) & t_A <= closing_time){
      customer_id <- customer_id + 1
      N <- N + 1
      t <- t_A
      N_S <- N_S + 1
      t_S <- t + generate.shopping.time()
      
      # Adding Customer to data frame
      
      df[nrow(df) + 1,] <- c(customer_id, t_A, t_S, NA, NA, NA) 
      
      shopping_customers <-  append(shopping_customers, customer_id)
      shopping_finish_times <- append(shopping_finish_times, t_S)
      t_S <- if (length(shopping_finish_times) > 0) min(shopping_finish_times) else Inf
      t_A <- t + generate.time.till.next.customer()
      
    } else if(t_S <= min(t_A, t_D, t_S) & N_S >0 & length(shopping_customers)!=0){
      N_S <- N_S - 1
      t <- t_S  
      
      index_s <- match(t_S,shopping_finish_times)
      
      counter <- choose.counter(nc1, nc2, nc3, nc4)
      
      if (counter == 1){
        t_A_1 <- t
        nc1 <- nc1 + 1
        
        customer_id_counter_1 <- append(customer_id_counter_1, shopping_customers[index_s])
        
        if (nc1 == 1){
          service_start_times_1 <- append(service_start_times_1, t)
          t_D_1 <-  t + generate.service.time(service_time_counter_1)
        }
        
      }else if (counter == 2){
        t_A_2 <- t
        nc2 <- nc2 + 1
        
        customer_id_counter_2 <- append(customer_id_counter_2, shopping_customers[index_s])
        
        if (nc2 == 1){
          service_start_times_2 <- append(service_start_times_2, t)
          t_D_2 <-  t + generate.service.time(service_time_counter_2)
        }
      }else if (counter == 3){
        t_A_3 <- t
        nc3 <- nc3 + 1
        
        customer_id_counter_3 <- append(customer_id_counter_3, shopping_customers[index_s])
        
        if (nc3 == 1){
          service_start_times_3 <- append(service_start_times_3, t)
          t_D_3 <-t +  generate.service.time(service_time_counter_3)
        }
      }else if (counter == 4){
        t_A_4 <- t
        nc4 <- nc4 + 1
        
        customer_id_counter_4 <- append(customer_id_counter_4, shopping_customers[index_s])
        
        if (nc4 == 1){
          service_start_times_4 <- append(service_start_times_4, t)
          t_D_4 <- t + generate.service.time(service_time_counter_4)
        }
      }
      
      shopping_customers <- shopping_customers[-index_s]
      shopping_finish_times <- shopping_finish_times[-index_s]
      t_S <- if (length(shopping_finish_times) > 0) min(shopping_finish_times) else Inf
      
      
    }else if (N > 0){
      N <- N - 1
      if (t_D != Inf){
        t <- t_D 
      }
      
      
      
      if (t_D_1 == t_D & nc1 > 0){
        nc1 <- nc1 - 1
        departure_times_counter_1 <- append(departure_times_counter_1, t)
        
        if (nc1 > 0){
          service_start_times_1 <- append(service_start_times_1, t)
          t_D_1 <- t + generate.service.time(service_time_counter_1)
          t_C_1 <- t_C_1 + t_D_1 - t
        }else if (nc1 > 0){
          t_D_1 <- Inf
        }
        
      }else if (t_D_2 == t_D & nc2 > 0){
        nc2 <- nc2 - 1
        departure_times_counter_2 <- append(departure_times_counter_2, t)
        
        
        if (nc2 > 0){
          service_start_times_2 <- append(service_start_times_2, t)
          t_D_2 <- t + generate.service.time(service_time_counter_2)
          t_C_2 <- t_C_2 + t_D_2 - t
        }else if (nc2 > 0){
          t_D_2 <- Inf
        }
        
      }else if (t_D_3 == t_D & nc3 > 0){
        nc3 <- nc3 - 1 
        departure_times_counter_3 <- append(departure_times_counter_3, t)
        
        
        if (nc3 > 0){
          service_start_times_3 <- append(service_start_times_3, t)
          t_D_3 <- t + generate.service.time(service_time_counter_3)
          t_C_3 <- t_C_3 + t_D_3 - t
        }else if (nc3 > 0){
          t_D_3 <- Inf
        }
        
      }else if (t_D_4 == t_D & nc4 > 0){
        nc4 <- nc4 - 1 
        departure_times_counter_4 <- append(departure_times_counter_4, t)
        
        
        if (nc4 > 0){
          service_start_times_4 <- append(service_start_times_4, t)
          t_D_4 <- t + generate.service.time(service_time_counter_4)
          t_C_4 <- t_C_4 + t_D_4 - t
        }else if (nc4 > 0){
          t_D_4 <- Inf
        }
        
      }else{
        print("No condition")
      }
      
    }else{
      t <- closing_time
    }
    
  }
  
  df_counter_1 <- data.frame (
    Customer_id = customer_id_counter_1,
    Service_start_time = service_start_times_1,
    Departure_time = departure_times_counter_1,
    Counter = 1
  )
  
  df_counter_2 <- data.frame (
    Customer_id = customer_id_counter_2,
    Service_start_time = service_start_times_2,
    Departure_time = departure_times_counter_2,
    Counter = 2
  )
  
  df_counter_3 <- data.frame (
    Customer_id = customer_id_counter_3,
    Service_start_time = service_start_times_3,
    Departure_time = departure_times_counter_3,
    Counter = 3
  )
  
  df_counter_4 <- data.frame (
    Customer_id = customer_id_counter_4,
    Service_start_time = service_start_times_4,
    Departure_time = departure_times_counter_4,
    Counter = 4
    
  )
  
  
  final_df <- rows_update(df, df_counter_1, by="Customer_id") %>%
    rows_update(df_counter_2, by="Customer_id") %>%
    rows_update(df_counter_3, by="Customer_id") %>%
    rows_update(df_counter_4, by="Customer_id")
  
  final_df$Waiting_time <- final_df$Service_start_time - final_df$Shopping_finish_time
  final_df$Total_time_spent <- final_df$Departure_time - final_df$Arrival_time
  
  
  return(list(cust_data = final_df,
              total_cust = customer_id,
              c1_cust = length(customer_id_counter_1),
              c2_cust = length(customer_id_counter_2),
              c3_cust = length(customer_id_counter_3),
              c4_cust = length(customer_id_counter_4),
              c1_used = t_C_1,
              c2_used = t_C_2,
              c3_used = t_C_3,
              c4_used = t_C_4,
              finish_t = t))
  
}

run_simulation <- function(runs = 10){
  
  df <- data.frame(matrix(ncol = 10, nrow = 0))
  colnames(df) <- c("avg_Wait_c1",
                    "avg_Wait_c2",
                    "avg_Wait_c3",
                    "avg_Wait_c4",
                    "avg_t_spent",
                    "util_c1",
                    "util_c2",
                    "util_c3",
                    "util_c4",
                    "total_cust")
  
  for (i in 1:runs){
    print(paste("Simulation Run: ", i))
    Result <- simulate_shop()
    
    customer_data <- Result$cust_data
    
    
    
    avg_waiting_time_c1 <- if(Result$c1_cust > 0) sum(customer_data[customer_data$Counter == 1,]$Waiting_time) / Result$c1_cust else 0
    avg_waiting_time_c2 <- if(Result$c2_cust > 0) sum(customer_data[customer_data$Counter == 2,]$Waiting_time) / Result$c2_cust else 0
    avg_waiting_time_c3 <- if(Result$c3_cust > 0) sum(customer_data[customer_data$Counter == 3,]$Waiting_time) / Result$c3_cust else 0
    avg_waiting_time_c4 <- if(Result$c4_cust > 0) sum(customer_data[customer_data$Counter == 4,]$Waiting_time) / Result$c4_cust else 0
    
    avg_time_spent <- sum(customer_data$Total_time_spent) / Result$total_cust
    
    u_c1 <- Result$c1_used / Result$finish_t
    u_c2 <- Result$c2_used / Result$finish_t
    u_c3 <- Result$c3_used / Result$finish_t
    u_c4 <- Result$c4_used / Result$finish_t
    
    df[nrow(df) + 1,] <- c(avg_waiting_time_c1,
                           avg_waiting_time_c2,
                           avg_waiting_time_c3,
                           avg_waiting_time_c4,
                           avg_time_spent,
                           u_c1,
                           u_c2,
                           u_c3,
                           u_c4,
                           Result$total_cust
    )
    
  }
  
  return(df)
  
  
  
}

Final_Result <- run_simulation(runs = 1000)


print(paste("Average Waiting Time For Counter 1:",mean(Final_Result$avg_Wait_c1)))
print(paste("Average Waiting Time For Counter 2:",mean(Final_Result$avg_Wait_c2)))
print(paste("Average Waiting Time For Counter 3:",mean(Final_Result$avg_Wait_c3)))
print(paste("Average Waiting Time For Counter 4:",mean(Final_Result$avg_Wait_c4)))


print(paste("Average Time Spent:",mean(Final_Result$avg_t_spent)))

print(paste("Utilization Counter 1: ", round(mean(Final_Result$util_c1)*100,2), "%"))
print(paste("Utilization Counter 2: ", round(mean(Final_Result$util_c2)*100,2), "%"))
print(paste("Utilization Counter 3: ", round(mean(Final_Result$util_c3)*100,2), "%"))
print(paste("Utilization Counter 4: ", round(mean(Final_Result$util_c4)*100,2), "%"))

print(paste("Total Customers: ", round(mean(Final_Result$total_cust))))


plot(Final_Result$avg_Wait_c1, pch=16, xlab = "Run", ylab = "Average Waiting time of counter 1")
abline(h = mean(Final_Result$avg_Wait_c1), col="red")

plot(Final_Result$avg_Wait_c2, pch=16, xlab = "Run", ylab = "Average Waiting time of counter 2")
abline(h = mean(Final_Result$avg_Wait_c2), col="red")

plot(Final_Result$avg_Wait_c3, pch=16, xlab = "Run", ylab = "Average Waiting time of counter 3")
abline(h = mean(Final_Result$avg_Wait_c3), col="red")

plot(Final_Result$avg_Wait_c4, pch=16, xlab = "Run", ylab = "Average Waiting time of counter 4")
abline(h = mean(Final_Result$avg_Wait_c4), col="red")

plot(Final_Result$total_cust, pch=16, xlab = "Run", ylab = "Total Cusotmers")
abline(h = round(mean(Final_Result$total_cust)), col="red")



