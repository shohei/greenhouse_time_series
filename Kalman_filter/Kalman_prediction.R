co2 <- read.table('co2.csv')
y <- ts(co2)
t_max <- nrow(y)

Kalman_filtering <- function(m_t_minus_1, C_t_minus_1, t){
  a_t <- G_t %*% m_t_minus_1
  R_t <- G_t %*% C_t_minus_1 %*% t(G_t) + W_t

  f_t <- F_t %*% a_t
  Q_t <- F_t %*% R_t %*% t(F_t) + V_t

  K_t <- R_t %*% t(F_t) %*% solve(Q_t)

  m_t <- a_t + K_t %*% (y[t] - f_t)
  C_t <- (diag(nrow(R_t)) - K_t %*% F_t) %*% R_t

  return(list(m = m_t, C = C_t,
              a = a_t, R = R_t))
}

G_t <- matrix(1, ncol = 1, nrow = 1); W_t <- matrix(exp(7.29), ncol = 1, nrow = 1)
F_t <- matrix(1, ncol = 1, nrow = 1); V_t <- matrix(exp(9.62), ncol = 1, nrow = 1)
 m0 <- matrix(0, ncol = 1, nrow = 1);  C0 <- matrix(     1e+7, ncol = 1, nrow = 1)

m <- rep(NA_real_, t_max); C <- rep(NA_real_, t_max)
a <- rep(NA_real_, t_max); R <- rep(NA_real_, t_max)

KF <- Kalman_filtering(m0, C0, t = 1)
m[1] <- KF$m; C[1] <- KF$C
a[1] <- KF$a; R[1] <- KF$R

for (t in 2:t_max){
  KF <- Kalman_filtering(m[t-1], C[t-1], t = t)
  m[t] <- KF$m; C[t] <- KF$C
  a[t] <- KF$a; R[t] <- KF$R
}

m_sdev <- sqrt(C)
m_quant <- list(m + qnorm(0.025, sd = m_sdev), m + qnorm(0.975, sd = m_sdev))

ts.plot(cbind(y, m, do.call("cbind", m_quant)),
        col = c("lightgray", "black", "black", "black"),
        lty = c("solid", "solid", "dashed", "dashed"))

legend(legend = c("観測値", "平均 (フィルタリング分布)", "95%区間 (フィルタリング分布)"),
       lty = c("solid", "solid", "dashed"),
       col = c("lightgray", "black", "black"),
       x = "topright", cex = 0.6)

t <- t_max    # 最終時点から
nAhead <- 100  # 10時点分先まで

Kalman_prediction <- function(a_t0, R_t0){
  a_t1 <- G_t_plus_1 %*% a_t0
  R_t1 <- G_t_plus_1 %*% R_t0 %*% t(G_t_plus_1) + W_t_plus_1

  return(list(a = a_t1, R = R_t1))
}

G_t_plus_1 <- G_t; W_t_plus_1 <- W_t

a_ <- rep(NA_real_, t_max + nAhead); R_ <- rep(NA_real_, t_max + nAhead)

a_[t + 0] <- m[t]; R_[t + 0] <- C[t]

for (k in 1:nAhead){
  KP <- Kalman_prediction(a_[t + k-1], R_[t + k-1])
  a_[t + k] <- KP$a; R_[t + k] <- KP$R
}

a_ <- ts(a_, start = 1)
a_sdev <- sqrt(R_)
a_quant <- list(a_ + qnorm(0.025, sd = a_sdev), a_ + qnorm(0.975, sd = a_sdev))

ts.plot(cbind(y, a_, do.call("cbind", a_quant)),
        col = c("lightgray", "black", "black", "black"),
        lty = c("solid", "solid", "dashed", "dashed"))

legend(legend = c("観測値", "平均 (予測分布)", "95%区間 (予測分布)"),
       lty = c("solid", "solid", "dashed"),
       col = c("lightgray", "black", "black"),
       x = "topright", cex = 0.6)

